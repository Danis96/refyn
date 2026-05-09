import 'dart:developer' as developer;

import 'package:refyn/app/features/budgets/repository/monthly_budget_sync_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:refyn/app/features/scan/repository/gemma_receipt_mapper.dart';
import 'package:refyn/app/features/scan/repository/gemma_receipt_scan_service.dart';
import 'package:refyn/app/features/scan/repository/scan_failure.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_repository.dart';
import 'package:refyn/app/shared/services/currency_conversion_service.dart';
import 'package:refyn/app/shared/utils/app_currency_utils.dart';
import 'package:refyn/app/models/receipt/receipt_db_mapper.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/models/receipt/receipt_validator.dart';
import 'package:refyn/database/app_database.dart';
import 'package:refyn/l10n/app_localizations.dart';

class ScanRepository {
  ScanRepository({
    required ReceiptDao receiptDao,
    required AppSettingsDao settingsDao,
    required GemmaReceiptScanService gemmaService,
    required MonthlyBudgetSyncRepository monthlyBudgetSyncRepository,
    required CurrencyConversionService currencyConversionService,
    required TravelModeRepository travelModeRepository,
    ImagePicker? imagePicker,
  }) : _receiptDao = receiptDao,
       _settingsDao = settingsDao,
       _gemmaService = gemmaService,
       _monthlyBudgetSyncRepository = monthlyBudgetSyncRepository,
       _currencyConversionService = currencyConversionService,
       _travelModeRepository = travelModeRepository,
       _imagePicker = imagePicker ?? ImagePicker();

  final ReceiptDao _receiptDao;
  final AppSettingsDao _settingsDao;
  final GemmaReceiptScanService _gemmaService;
  final MonthlyBudgetSyncRepository _monthlyBudgetSyncRepository;
  final CurrencyConversionService _currencyConversionService;
  final TravelModeRepository _travelModeRepository;
  final ImagePicker _imagePicker;

  Future<String?> pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    return image?.path;
  }

  Future<String?> pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    return image?.path;
  }

  Future<List<ReceiptModel>> getRecentReceipts({int limit = 2}) async {
    final List<ReceiptWithItems> rows = await _receiptDao
        .getRecentReceiptsWithItems(limit);
    return rows
        .map((ReceiptWithItems row) => row.toReceiptModel())
        .toList(growable: false);
  }

  Future<ReceiptModel> scanReceipt({required String imagePath}) async {
    try {
      final String homeCurrency = await _getDefaultCurrency();
      final TravelModeState travelState = await _travelModeRepository
          .getState();
      final String targetCurrency = travelState.isActive
          ? travelState.tripCurrency ?? homeCurrency
          : homeCurrency;

      final Map<String, dynamic> aiPayload = await _gemmaService
          .scanReceiptImage(
            imagePath: imagePath,
            defaultCurrency: targetCurrency,
          );
      if (_isNotAReceipt(aiPayload)) {
        final String reason = _notAReceiptReason(aiPayload);
        developer.log(
          'Rejected non-receipt image. imagePath=$imagePath reason=$reason',
          name: 'ScanRepository',
        );
        throw ScanException(
          ScanFailure(
            type: ScanFailureType.notReceipt,
            title: AppLocalizations.current.notReceiptTitle,
            message: AppLocalizations.current.notReceiptMessage(reason),
            technicalDetails: reason.isEmpty ? null : reason,
          ),
        );
      }
      if (_hasImageQualityIssue(aiPayload)) {
        final String reason = _imageQualityIssueReason(aiPayload);
        developer.log(
          'Rejected low-quality receipt image. imagePath=$imagePath reason=$reason',
          name: 'ScanRepository',
        );
        throw ScanException(
          ScanFailure(
            type: ScanFailureType.imageQualityIssue,
            title: AppLocalizations.current.imageQualityIssueTitle,
            message: AppLocalizations.current.imageQualityIssueMessage(reason),
            technicalDetails: reason.isEmpty ? null : reason,
          ),
        );
      }

      final ReceiptModel scannedRaw = GemmaReceiptMapper.toReceiptModel(
        payload: aiPayload,
        imagePath: imagePath,
        defaultCurrency: targetCurrency,
      );

      final ReceiptModel scanned = travelState.isActive
          ? scannedRaw.copyWithTravelSessionId(travelState.sessionId)
          : scannedRaw;

      if (!_currencyConversionService.needsConversion(
        scanned.currency,
        targetCurrency,
      )) {
        return scanned;
      }

      try {
        final ConversionResult result = await _currencyConversionService
            .getRate(from: scanned.currency, to: targetCurrency);
        developer.log(
          'Converted receipt ${scanned.currency}→$targetCurrency rate=${result.rate}'
          '${travelState.isActive ? ' (travel mode)' : ''}',
          name: 'ScanRepository',
        );
        return scanned.convertedTo(
          rate: result.rate,
          currency: targetCurrency,
        );
      } on CurrencyConversionException catch (error) {
        throw ScanException(
          ScanFailure(
            type: ScanFailureType.currencyConversionFailed,
            title: AppLocalizations.current.currencyConversionFailedTitle,
            message: AppLocalizations.current.currencyConversionFailedMessage(
              scanned.currency,
              targetCurrency,
            ),
            technicalDetails: error.message,
          ),
        );
      }
    } on ScanException {
      rethrow;
    } on GemmaScanException catch (error) {
      final ScanFailure failure = _failureFromGemmaError(error.message);
      throw ScanException(failure);
    } catch (error) {
      throw ScanException(
        ScanFailure(
          type: ScanFailureType.parseFailure,
          title: AppLocalizations.current.scanFailedTitle,
          message: AppLocalizations.current.scanFailedMessage,
          technicalDetails: error.toString(),
        ),
      );
    }
  }

  Future<void> saveReceipt(ReceiptModel receipt) async {
    final List<String> modelErrors = ReceiptSaveValidator.validateModel(
      receipt,
    );
    if (modelErrors.isNotEmpty) {
      throw ScanException(
        ScanFailure(
          type: ScanFailureType.parseFailure,
          title: AppLocalizations.current.cannotSaveReceiptTitle,
          message: AppLocalizations.current.cannotSaveReceiptMessage,
          technicalDetails: modelErrors.join('; '),
        ),
      );
    }
    await _receiptDao.upsertReceiptWithItems(
      receipt.toReceiptCompanion(),
      receipt.toReceiptItemsCompanions(),
    );
    await _monthlyBudgetSyncRepository.syncCurrentMonth();
  }

  ScanFailure _failureFromGemmaError(String message) {
    final String lowered = message.toLowerCase();
    if (lowered.contains('invalid structured json payload') ||
        lowered.contains('invalid json envelope') ||
        lowered.contains('not a json object')) {
      return ScanFailure(
        type: ScanFailureType.invalidJson,
        title: AppLocalizations.current.invalidJsonResponseTitle,
        message: AppLocalizations.current.invalidJsonResponseMessage,
        technicalDetails: message,
      );
    }
    return ScanFailure(
      type: ScanFailureType.aiResponseFailed,
      title: AppLocalizations.current.aiResponseFailedTitle,
      message: AppLocalizations.current.aiResponseFailedMessage,
      technicalDetails: message,
    );
  }

  bool _isNotAReceipt(Map<String, dynamic> payload) {
    final dynamic rawValue = payload['notAReceipt'];
    if (rawValue is bool) {
      return rawValue;
    }
    if (rawValue is String) {
      return rawValue.trim().toLowerCase() == 'true';
    }
    return false;
  }

  String _notAReceiptReason(Map<String, dynamic> payload) {
    return _normalizedReason(payload);
  }

  bool _hasImageQualityIssue(Map<String, dynamic> payload) {
    final dynamic rawValue = payload['imageQualityIssue'];
    if (rawValue is bool) {
      return rawValue;
    }
    if (rawValue is String) {
      return rawValue.trim().toLowerCase() == 'true';
    }
    return false;
  }

  String _imageQualityIssueReason(Map<String, dynamic> payload) {
    return _normalizedReason(payload);
  }

  String _normalizedReason(Map<String, dynamic> payload) {
    final String reason = payload['reason']?.toString().trim() ?? '';
    if (reason.isEmpty) {
      return '';
    }
    return reason.endsWith('.') ? reason : '$reason.';
  }

  Future<String> _getDefaultCurrency() async {
    final String? value = await _settingsDao.getSetting('currency_code');
    return AppCurrencyUtils.normalizeCode(value);
  }
}
