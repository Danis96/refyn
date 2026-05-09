import 'package:flutter/foundation.dart';

import '../models/introduction_step.dart';
import '../repository/introduction_repository.dart';

class IntroductionProvider extends ChangeNotifier {
  IntroductionProvider({required IntroductionRepository repository})
    : _repository = repository;

  final IntroductionRepository _repository;

  List<IntroductionStep> _steps = const <IntroductionStep>[];
  int _currentPage = 0;
  bool _isCompleting = false;
  bool _isLoading = true;
  bool _hasSeenIntroduction = false;
  bool _hasHomeCurrency = false;

  List<IntroductionStep> get steps => _steps;
  int get currentPage => _currentPage;
  bool get isCompleting => _isCompleting;
  bool get isLoading => _isLoading;
  bool get hasSeenIntroduction => _hasSeenIntroduction;
  bool get hasHomeCurrency => _hasHomeCurrency;
  bool get hasSteps => _steps.isNotEmpty;
  bool get isLastPage => _steps.isNotEmpty && _currentPage == _steps.length - 1;
  bool get shouldShowIntroduction => !_isLoading && !_hasSeenIntroduction;
  bool get shouldShowHomeCurrencyPicker =>
      !_isLoading && _hasSeenIntroduction && !_hasHomeCurrency;

  Future<void> initialize() async {
    _steps = _repository.loadSteps();
    _hasSeenIntroduction = await _repository.hasSeenIntroduction();
    _hasHomeCurrency = await _repository.hasHomeCurrency();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setHomeCurrency(String code) async {
    await _repository.setHomeCurrency(code);
    _hasHomeCurrency = true;
    notifyListeners();
  }

  void setCurrentPage(int page) {
    if (page == _currentPage) {
      return;
    }

    _currentPage = page;
    notifyListeners();
  }

  Future<void> complete() async {
    if (_isCompleting) {
      return;
    }

    _isCompleting = true;
    notifyListeners();

    await _repository.markIntroductionSeen();

    _hasSeenIntroduction = true;
    _isCompleting = false;
    notifyListeners();
  }
}
