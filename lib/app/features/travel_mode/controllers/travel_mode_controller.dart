import 'package:flutter/foundation.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_repository.dart';
import 'package:refyn/app/models/receipt/receipt_db_mapper.dart';
import 'package:refyn/app/models/receipt/receipt_model.dart';
import 'package:refyn/app/features/travel_mode/repository/travel_mode_service.dart';
import 'package:refyn/database/app_database.dart';

class TravelModeController extends ChangeNotifier {
  TravelModeController({
    required TravelModeService service,
    required ReceiptDao receiptDao,
  }) : _service = service,
       _receiptDao = receiptDao;

  final TravelModeService _service;
  final ReceiptDao _receiptDao;

  TravelModeState _state = const TravelModeState.inactive();
  String _homeCurrency = 'BAM';
  double _tripSpend = 0;
  int _tripReceiptCount = 0;
  bool _loading = false;
  bool _isStarting = false;
  bool _isEnding = false;
  TripEndProgress? _endProgress;

  TravelModeState get state => _state;
  bool get isActive => _state.isActive;
  String? get tripCurrency => _state.tripCurrency;
  int? get sessionId => _state.sessionId;
  DateTime? get startedAt => _state.startedAt;
  String get homeCurrency => _homeCurrency;
  double get tripSpend => _tripSpend;
  int get tripReceiptCount => _tripReceiptCount;
  bool get loading => _loading;
  bool get isStarting => _isStarting;
  bool get isEnding => _isEnding;
  TripEndProgress? get endProgress => _endProgress;

  int get tripDayNumber {
    final DateTime? start = _state.startedAt;
    if (start == null) {
      return 0;
    }
    final DateTime startDay = DateTime(start.year, start.month, start.day);
    final DateTime today = DateTime.now();
    final DateTime todayDay = DateTime(today.year, today.month, today.day);
    return todayDay.difference(startDay).inDays + 1;
  }

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      _homeCurrency = await _service.getHomeCurrency();
      _state = await _service.getState();
      await _refreshTripStats();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _homeCurrency = await _service.getHomeCurrency();
    _state = await _service.getState();
    await _refreshTripStats();
    notifyListeners();
  }

  Future<void> startTrip(String currency) async {
    if (_isStarting || _state.isActive) {
      return;
    }
    _isStarting = true;
    notifyListeners();
    try {
      _state = await _service.startTrip(currency);
      await _refreshTripStats();
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  Future<TripEndResult> endTrip({required TripEndStrategy strategy}) async {
    _isEnding = true;
    _endProgress = null;
    notifyListeners();
    try {
      final TripEndResult result = await _service.endTrip(
        strategy: strategy,
        onProgress: (TripEndProgress progress) {
          _endProgress = progress;
          notifyListeners();
        },
      );
      _state = const TravelModeState.inactive();
      _tripSpend = 0;
      _tripReceiptCount = 0;
      return result;
    } finally {
      _isEnding = false;
      _endProgress = null;
      notifyListeners();
    }
  }

  Future<List<ReceiptModel>> loadActiveTripReceipts() async {
    final int? activeSessionId = _state.sessionId;
    if (!_state.isActive || activeSessionId == null) {
      return const <ReceiptModel>[];
    }

    final List<ReceiptWithItems> rows = await _receiptDao
        .getReceiptsWithItemsBySessionId(activeSessionId);
    return rows
        .map((ReceiptWithItems row) => row.toReceiptModel())
        .toList(growable: false);
  }

  Future<void> _refreshTripStats() async {
    final int? sessionId = _state.sessionId;
    if (!_state.isActive || sessionId == null) {
      _tripSpend = 0;
      _tripReceiptCount = 0;
      return;
    }
    _tripSpend = await _receiptDao.getTripSpendTotal(sessionId);
    _tripReceiptCount = await _receiptDao.getTripReceiptCount(sessionId);
  }
}
