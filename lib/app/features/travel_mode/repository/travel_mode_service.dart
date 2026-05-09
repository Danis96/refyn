import 'dart:developer' as developer;

import 'package:refyn/app/features/budgets/repository/monthly_budget_sync_repository.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_repository.dart';
import 'package:refyn/app/models/receipt/receipt_db_mapper.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/shared/services/currency_conversion_service.dart';
import 'package:refyn/app/shared/utils/app_currency_utils.dart';
import 'package:refyn/database/app_database.dart';

enum TripEndStrategy { todaysRate, perDayRates }

enum TripEndStep { fetchingRate, fetchingHistorical, converting, finishing }

class TripEndProgress {
  const TripEndProgress({
    required this.step,
    required this.percent,
    this.dateKey,
  });

  final TripEndStep step;
  final double percent;
  final String? dateKey;
}

class TripEndResult {
  const TripEndResult({
    required this.fromCurrency,
    required this.toCurrency,
    required this.receiptsConverted,
    required this.strategy,
  });

  final String fromCurrency;
  final String toCurrency;
  final int receiptsConverted;
  final TripEndStrategy strategy;
}

/// Coordinates trip start, scan-time targeting (via [TravelModeRepository]
/// state), and trip-end conversion of every persisted trip receipt to the
/// home currency at either today's rate or per-day rates.
class TravelModeService {
  TravelModeService({
    required AppDatabase database,
    required ReceiptDao receiptDao,
    required AppSettingsDao settingsDao,
    required TravelModeRepository travelModeRepository,
    required CurrencyConversionService conversionService,
    required MonthlyBudgetSyncRepository monthlyBudgetSyncRepository,
  }) : _database = database,
       _receiptDao = receiptDao,
       _settingsDao = settingsDao,
       _travelModeRepository = travelModeRepository,
       _conversionService = conversionService,
       _monthlyBudgetSyncRepository = monthlyBudgetSyncRepository;

  final AppDatabase _database;
  final ReceiptDao _receiptDao;
  final AppSettingsDao _settingsDao;
  final TravelModeRepository _travelModeRepository;
  final CurrencyConversionService _conversionService;
  final MonthlyBudgetSyncRepository _monthlyBudgetSyncRepository;

  static const String _homeCurrencyKey = 'currency_code';

  Future<String> getHomeCurrency() async {
    final String? value = await _settingsDao.getSetting(_homeCurrencyKey);
    return AppCurrencyUtils.normalizeCode(value);
  }

  Future<TravelModeState> getState() => _travelModeRepository.getState();

  Future<TravelModeState> startTrip(String currency) {
    return _travelModeRepository.startTrip(currency);
  }

  /// Loads all receipts for the active trip, fetches conversion rates per
  /// [strategy], converts each receipt to the home currency, clears its
  /// travel session id, and saves back — all atomically. Throws
  /// [CurrencyConversionException] if any rate fetch fails (DB untouched).
  Future<TripEndResult> endTrip({
    required TripEndStrategy strategy,
    void Function(TripEndProgress progress)? onProgress,
  }) async {
    final TravelModeState state = await _travelModeRepository.getState();
    if (!state.isActive ||
        state.sessionId == null ||
        state.tripCurrency == null) {
      throw StateError('No active trip to end.');
    }

    final String fromCurrency = state.tripCurrency!;
    final String toCurrency = await getHomeCurrency();
    final int sessionId = state.sessionId!;

    final List<ReceiptWithItems> rows = await _receiptDao
        .getReceiptsWithItemsBySessionId(sessionId);

    if (rows.isEmpty) {
      // Edge case: trip ended with zero scans. Just clear flags.
      await _travelModeRepository.clearTrip();
      await _monthlyBudgetSyncRepository.syncCurrentMonth();
      return TripEndResult(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        receiptsConverted: 0,
        strategy: strategy,
      );
    }

    final List<ReceiptModel> models = rows
        .map((ReceiptWithItems row) => row.toReceiptModel())
        .toList(growable: false);

    onProgress?.call(
      TripEndProgress(
        step: strategy == TripEndStrategy.perDayRates
            ? TripEndStep.fetchingHistorical
            : TripEndStep.fetchingRate,
        percent: 0,
      ),
    );

    final Map<String, double> ratesByDateKey;
    if (fromCurrency == toCurrency) {
      ratesByDateKey = const <String, double>{};
    } else if (strategy == TripEndStrategy.perDayRates) {
      ratesByDateKey = await _fetchPerDayRates(
        receipts: models,
        from: fromCurrency,
        to: toCurrency,
        onProgress: onProgress,
      );
    } else {
      final ConversionResult result = await _conversionService.getRate(
        from: fromCurrency,
        to: toCurrency,
      );
      ratesByDateKey = <String, double>{'__today__': result.rate};
    }

    onProgress?.call(
      TripEndProgress(step: TripEndStep.converting, percent: 0.85),
    );

    await _database.transaction(() async {
      for (final ReceiptModel model in models) {
        final double rate = strategy == TripEndStrategy.perDayRates
            ? ratesByDateKey[_dateKeyFor(model)] ?? 1
            : (ratesByDateKey['__today__'] ?? 1);
        final ReceiptModel converted = (rate == 1 && fromCurrency == toCurrency)
            ? model.copyWithTravelSessionId(null)
            : model
                  .convertedTo(rate: rate, currency: toCurrency)
                  .copyWithTravelSessionId(null);

        await _receiptDao.upsertReceiptWithItems(
          converted.toReceiptCompanion(),
          converted.toReceiptItemsCompanions(),
        );
      }
      await _travelModeRepository.clearTrip();
    });

    await _monthlyBudgetSyncRepository.syncCurrentMonth();

    onProgress?.call(
      TripEndProgress(step: TripEndStep.finishing, percent: 1),
    );

    developer.log(
      'Trip ended $fromCurrency→$toCurrency receipts=${models.length} strategy=$strategy',
      name: 'TravelModeService',
    );

    return TripEndResult(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      receiptsConverted: models.length,
      strategy: strategy,
    );
  }

  // ─── private ──────────────────────────────────────────────────────────────

  Future<Map<String, double>> _fetchPerDayRates({
    required List<ReceiptModel> receipts,
    required String from,
    required String to,
    void Function(TripEndProgress progress)? onProgress,
  }) async {
    final Map<String, DateTime> uniqueDates = <String, DateTime>{};
    for (final ReceiptModel m in receipts) {
      final DateTime d = _effectiveDateFor(m);
      uniqueDates[_formatDate(d)] = d;
    }

    final List<MapEntry<String, DateTime>> entries = uniqueDates.entries
        .toList(growable: false);
    final int total = entries.length;

    int completed = 0;
    final Map<String, double> result = <String, double>{};
    final List<Future<void>> futures = entries.map((entry) async {
      final double rate = await _conversionService.getHistoricalRate(
        date: entry.value,
        from: from,
        to: to,
      );
      result[entry.key] = rate;
      completed += 1;
      onProgress?.call(
        TripEndProgress(
          step: TripEndStep.fetchingHistorical,
          percent: 0.05 + 0.7 * (completed / total),
          dateKey: entry.key,
        ),
      );
    }).toList();

    await Future.wait<void>(futures);
    return result;
  }

  String _dateKeyFor(ReceiptModel m) => _formatDate(_effectiveDateFor(m));

  DateTime _effectiveDateFor(ReceiptModel m) {
    return m.receiptInfo.dateTime ?? m.createdAt;
  }

  String _formatDate(DateTime date) {
    final DateTime utc = DateTime.utc(date.year, date.month, date.day);
    return utc.toIso8601String().substring(0, 10);
  }

}
