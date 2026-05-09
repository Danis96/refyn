import 'package:refyn/app/shared/utils/app_currency_utils.dart';
import 'package:refyn/database/app_database.dart';

class TravelModeState {
  const TravelModeState({
    required this.isActive,
    required this.tripCurrency,
    required this.sessionId,
    required this.startedAt,
  });

  const TravelModeState.inactive()
    : isActive = false,
      tripCurrency = null,
      sessionId = null,
      startedAt = null;

  final bool isActive;
  final String? tripCurrency;
  final int? sessionId;
  final DateTime? startedAt;
}

/// Reads and writes the travel-mode flags stored in the [AppSettings] table.
/// One active trip at a time. Session ids are monotonically increasing
/// (millisecondsSinceEpoch at start) so they never collide across trips.
class TravelModeRepository {
  TravelModeRepository({required AppSettingsDao settingsDao})
    : _settingsDao = settingsDao;

  final AppSettingsDao _settingsDao;

  static const String _activeKey = 'travel_active';
  static const String _currencyKey = 'travel_currency';
  static const String _sessionIdKey = 'travel_session_id';
  static const String _startedAtKey = 'travel_started_at';

  Future<TravelModeState> getState() async {
    final String? activeRaw = await _settingsDao.getSetting(_activeKey);
    final bool isActive = activeRaw?.trim().toLowerCase() == 'true';
    if (!isActive) {
      return const TravelModeState.inactive();
    }
    final String? currency = await _settingsDao.getSetting(_currencyKey);
    final String? sessionRaw = await _settingsDao.getSetting(_sessionIdKey);
    final String? startedRaw = await _settingsDao.getSetting(_startedAtKey);
    final int? sessionId = int.tryParse(sessionRaw ?? '');
    final DateTime? startedAt = startedRaw == null
        ? null
        : DateTime.tryParse(startedRaw);

    if (currency == null || sessionId == null || startedAt == null) {
      return const TravelModeState.inactive();
    }

    return TravelModeState(
      isActive: true,
      tripCurrency: AppCurrencyUtils.normalizeCode(currency),
      sessionId: sessionId,
      startedAt: startedAt,
    );
  }

  Future<TravelModeState> startTrip(String currency) async {
    final String normalized = AppCurrencyUtils.normalizeCode(currency);
    final int sessionId = DateTime.now().millisecondsSinceEpoch;
    final DateTime startedAt = DateTime.now();

    await _settingsDao.upsertSetting(key: _activeKey, value: 'true');
    await _settingsDao.upsertSetting(key: _currencyKey, value: normalized);
    await _settingsDao.upsertSetting(
      key: _sessionIdKey,
      value: sessionId.toString(),
    );
    await _settingsDao.upsertSetting(
      key: _startedAtKey,
      value: startedAt.toIso8601String(),
    );

    return TravelModeState(
      isActive: true,
      tripCurrency: normalized,
      sessionId: sessionId,
      startedAt: startedAt,
    );
  }

  Future<void> clearTrip() async {
    await _settingsDao.upsertSetting(key: _activeKey, value: 'false');
    await _settingsDao.upsertSetting(key: _currencyKey, value: '');
    await _settingsDao.upsertSetting(key: _sessionIdKey, value: '');
    await _settingsDao.upsertSetting(key: _startedAtKey, value: '');
  }
}
