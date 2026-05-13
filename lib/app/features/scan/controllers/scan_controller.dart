import 'package:flutter/widgets.dart';
import 'package:refyn/l10n/app_localizations.dart';
import 'package:refyn/app/features/scan/controllers/scan_view_state.dart';
import 'package:refyn/app/features/scan/repository/scan_failure.dart';
import 'package:refyn/app/features/scan/repository/scan_repository.dart';
import 'package:refyn/app/models/receipt/merchant_model.dart';
import 'package:refyn/app/models/receipt/payment_info_model.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/models/receipt/receipt_totals_model.dart';

class ScanForegroundNotice {
  const ScanForegroundNotice({required this.message, required this.isError});

  final String message;
  final bool isError;
}

class ScanController extends ChangeNotifier with WidgetsBindingObserver {
  ScanController({required ScanRepository repository})
    : _repository = repository {
    WidgetsBinding.instance.addObserver(this);
  }

  final ScanRepository _repository;

  ScanViewState _state = ScanViewState.idle;
  final List<String> _selectedImagePaths = <String>[];
  ScanFailure? _failure;
  ReceiptModel? _lastScannedReceipt;
  ReceiptModel? _pendingReceiptDraft;
  int _loadingStep = 0;
  bool _busy = false;
  bool _savingDraft = false;
  List<ReceiptModel> _recentReceipts = const <ReceiptModel>[];
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  ScanForegroundNotice? _pendingForegroundNotice;
  int _activeScanRequestId = 0;
  int _lowConfidenceScanCount = 0;

  static const double lowConfidenceThreshold = 0.95;
  static const int thinkingModeSuggestionTriggerCount = 2;
  static const int maxImageCount = 3;

  ScanViewState get state => _state;
  List<String> get selectedImagePaths =>
      List<String>.unmodifiable(_selectedImagePaths);
  String? get selectedImagePath =>
      _selectedImagePaths.isEmpty ? null : _selectedImagePaths.first;
  bool get canAddMoreImages => _selectedImagePaths.length < maxImageCount;
  int get selectedImageCount => _selectedImagePaths.length;
  ScanFailure? get failure => _failure;
  String? get errorMessage => _failure?.message;
  ReceiptModel? get lastScannedReceipt => _lastScannedReceipt;
  ReceiptModel? get pendingReceiptDraft => _pendingReceiptDraft;
  bool get hasPendingReceiptDraft => _pendingReceiptDraft != null;
  bool get isLowConfidence =>
      (_pendingReceiptDraft ?? _lastScannedReceipt)?.confidence != null &&
      ((_pendingReceiptDraft ?? _lastScannedReceipt)!.confidence <
          lowConfidenceThreshold);
  int get lowConfidenceScanCount => _lowConfidenceScanCount;
  bool get shouldSuggestThinkingMode =>
      _lowConfidenceScanCount >= thinkingModeSuggestionTriggerCount;
  int get loadingStep => _loadingStep;
  bool get busy => _busy;
  bool get savingDraft => _savingDraft;
  List<ReceiptModel> get recentReceipts => _recentReceipts;

  ScanForegroundNotice? consumeForegroundNotice() {
    final ScanForegroundNotice? notice = _pendingForegroundNotice;
    if (notice != null) {
      _pendingForegroundNotice = null;
    }
    return notice;
  }

  /// Consumes the failure event, returning the failure and clearing it.
  /// This ensures a failure is only handled once by the UI.
  ScanFailure? consumeFailure() {
    final ScanFailure? consumedFailure = _failure;
    if (consumedFailure != null) {
      _failure = null;
    }
    return consumedFailure;
  }

  Future<void> initialize() async {
    await _loadRecentReceipts();
  }

  Future<void> pickFromGallery() async {
    if (!canAddMoreImages) {
      return;
    }
    await _runPicker(() async {
      final int remaining = maxImageCount - _selectedImagePaths.length;
      if (remaining <= 0) {
        return const <String>[];
      }
      if (remaining == 1) {
        final String? path = await _repository.pickImageFromGallery();
        return path == null ? const <String>[] : <String>[path];
      }
      return _repository.pickMultipleImagesFromGallery(limit: remaining);
    });
  }

  Future<void> pickFromCamera() async {
    if (!canAddMoreImages) {
      return;
    }
    await _runPicker(() async {
      final String? path = await _repository.pickImageFromCamera();
      return path == null ? const <String>[] : <String>[path];
    });
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= _selectedImagePaths.length) {
      return;
    }
    _selectedImagePaths.removeAt(index);
    if (_selectedImagePaths.isEmpty) {
      _state = ScanViewState.idle;
    } else {
      _state = ScanViewState.imageSelected;
    }
    _clearFailure();
    notifyListeners();
  }

  Future<void> _runPicker(Future<List<String>> Function() picker) async {
    if (_busy) {
      return;
    }

    _busy = true;
    _clearFailure();
    notifyListeners();

    try {
      final List<String> paths = await picker();
      final List<String> normalized = paths
          .map((String value) => value.trim())
          .where((String value) => value.isNotEmpty)
          .toList(growable: false);

      if (normalized.isEmpty) {
        _busy = false;
        notifyListeners();
        return;
      }

      for (final String path in normalized) {
        if (_selectedImagePaths.length >= maxImageCount) {
          break;
        }
        if (_selectedImagePaths.contains(path)) {
          continue;
        }
        _selectedImagePaths.add(path);
      }
      _state = ScanViewState.imageSelected;
    } catch (error) {
      _setFailure(
        ScanFailure(
          type: ScanFailureType.imageUploadFailed,
          title: AppLocalizations.current.scanImageUploadFailedTitle,
          message: AppLocalizations.current.scanImageUploadFailedMessage,
          technicalDetails: error.toString(),
        ),
      );
    }

    _busy = false;
    notifyListeners();
  }

  void clearSelection() {
    _activeScanRequestId++;
    _selectedImagePaths.clear();
    _clearFailure();
    _loadingStep = 0;
    _lastScannedReceipt = null;
    _pendingReceiptDraft = null;
    _state = ScanViewState.idle;
    notifyListeners();
  }

  Future<void> scanSelectedImage() async {
    if (_busy) {
      return;
    }

    final List<String> paths = List<String>.unmodifiable(_selectedImagePaths);
    if (paths.isEmpty) {
      _setFailure(
        ScanFailure(
          type: ScanFailureType.imageUploadFailed,
          title: AppLocalizations.current.scanNoImageSelectedTitle,
          message: AppLocalizations.current.scanNoImageSelectedMessage,
        ),
      );
      notifyListeners();
      return;
    }

    _busy = true;
    final int requestId = ++_activeScanRequestId;
    _state = ScanViewState.loading;
    _clearFailure();
    _loadingStep = 0;
    _lastScannedReceipt = null;
    _pendingReceiptDraft = null;
    notifyListeners();

    try {
      _advanceLoadingSteps();
      final ReceiptModel scanned = await _repository.scanReceipt(
        imagePaths: paths,
      );
      if (requestId != _activeScanRequestId) {
        return;
      }
      _pendingReceiptDraft = scanned;
      _lastScannedReceipt = scanned;
      if (scanned.confidence < lowConfidenceThreshold) {
        _lowConfidenceScanCount++;
      }
      _state = ScanViewState.success;
      _queueForegroundNoticeIfBackgrounded(
        ScanForegroundNotice(
          message: AppLocalizations.current.scanFinishedNotice,
          isError: false,
        ),
      );
    } on ScanException catch (error) {
      if (requestId != _activeScanRequestId) {
        return;
      }
      _setFailure(error.failure);
      _queueForegroundNoticeIfBackgrounded(
        ScanForegroundNotice(message: error.failure.message, isError: true),
      );
    } catch (error) {
      if (requestId != _activeScanRequestId) {
        return;
      }
      _setFailure(
        ScanFailure(
          type: ScanFailureType.parseFailure,
          title: AppLocalizations.current.scanUnexpectedFailureTitle,
          message: AppLocalizations.current.scanUnexpectedFailureMessage,
          technicalDetails: error.toString(),
        ),
      );
      _queueForegroundNoticeIfBackgrounded(
        ScanForegroundNotice(
          message: AppLocalizations.current.scanFailedNotice,
          isError: true,
        ),
      );
    }

    if (requestId != _activeScanRequestId) {
      return;
    }
    _busy = false;
    notifyListeners();
  }

  Future<void> saveDraftReceipt() async {
    if (_busy || _savingDraft || _pendingReceiptDraft == null) {
      return;
    }
    _savingDraft = true;
    _clearFailure();
    notifyListeners();
    try {
      await _repository.saveReceipt(_pendingReceiptDraft!);
      _pendingReceiptDraft = null;
      await _loadRecentReceipts();
    } on ScanException catch (error) {
      _setFailure(error.failure);
    } catch (error) {
      _setFailure(
        ScanFailure(
          type: ScanFailureType.parseFailure,
          title: AppLocalizations.current.scanSaveFailedTitle,
          message: AppLocalizations.current.scanSaveFailedMessage,
          technicalDetails: error.toString(),
        ),
      );
    }
    _savingDraft = false;
    notifyListeners();
  }

  void updateDraftReceipt({
    required String merchantName,
    required String paymentMethod,
    required double total,
  }) {
    final ReceiptModel? draft = _pendingReceiptDraft;
    if (draft == null) {
      return;
    }
    _pendingReceiptDraft = ReceiptModel(
      id: draft.id,
      country: draft.country,
      currency: draft.currency,
      merchant: MerchantModel(
        name: merchantName,
        storeName: draft.merchant.storeName,
        address: draft.merchant.address,
        city: draft.merchant.city,
        jib: draft.merchant.jib,
        pib: draft.merchant.pib,
      ),
      receiptInfo: draft.receiptInfo,
      items: draft.items,
      totals: ReceiptTotalsModel(
        total: total,
        subtotal: draft.totals.subtotal,
        discountTotal: draft.totals.discountTotal,
        taxableAmount: draft.totals.taxableAmount,
        vatRate: draft.totals.vatRate,
        vatAmount: draft.totals.vatAmount,
      ),
      payment: PaymentInfoModel(
        method: paymentMethod,
        paid: draft.payment.paid,
        change: draft.payment.change,
      ),
      category: draft.category,
      confidence: draft.confidence,
      createdAt: draft.createdAt,
      fiscal: draft.fiscal,
      rawText: draft.rawText,
      rawJson: draft.rawJson,
      imagePath: draft.imagePath,
    );
    _lastScannedReceipt = _pendingReceiptDraft;
    notifyListeners();
  }

  Future<void> showReadyToScan() async {
    _activeScanRequestId++;
    _selectedImagePaths.clear();
    _lastScannedReceipt = null;
    _pendingReceiptDraft = null;
    _clearFailure();
    _loadingStep = 0;
    _state = ScanViewState.idle;
    notifyListeners();
  }

  void cancelScan() {
    if (_state != ScanViewState.loading) {
      return;
    }

    _activeScanRequestId++;
    _busy = false;
    _loadingStep = 0;
    _lastScannedReceipt = null;
    _pendingReceiptDraft = null;
    _clearFailure();
    _state = _selectedImagePaths.isEmpty
        ? ScanViewState.idle
        : ScanViewState.imageSelected;
    notifyListeners();
  }

  Future<void> _loadRecentReceipts() async {
    _recentReceipts = await _repository.getRecentReceipts(limit: 2);
    notifyListeners();
  }

  Future<void> _advanceLoadingSteps() async {
    const List<int> delays = <int>[550, 550, 550, 550, 520];
    final int requestId = _activeScanRequestId;
    for (int i = 0; i < delays.length; i++) {
      if (requestId != _activeScanRequestId ||
          _state != ScanViewState.loading) {
        return;
      }
      _loadingStep = i + 1;
      notifyListeners();
      await Future<void>.delayed(Duration(milliseconds: delays[i]));
    }
  }

  void _setFailure(ScanFailure failure) {
    _failure = failure;
    _state = ScanViewState.error;
  }

  void _clearFailure() {
    _failure = null;
  }

  void _queueForegroundNoticeIfBackgrounded(ScanForegroundNotice notice) {
    if (_appLifecycleState == AppLifecycleState.resumed) {
      return;
    }
    _pendingForegroundNotice = notice;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (state == AppLifecycleState.resumed &&
        _pendingForegroundNotice != null) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @visibleForTesting
  void debugSetDraftReceipt(ReceiptModel? receipt) {
    _pendingReceiptDraft = receipt;
    _lastScannedReceipt = receipt;
    notifyListeners();
  }

  @visibleForTesting
  void debugSetLowConfidenceScanCount(int count) {
    _lowConfidenceScanCount = count;
    notifyListeners();
  }
}
