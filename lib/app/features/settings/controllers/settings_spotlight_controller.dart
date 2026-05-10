import 'package:flutter/foundation.dart';

enum SettingsSpotlightTarget { thinkingMode }

class SettingsSpotlightController extends ChangeNotifier {
  SettingsSpotlightTarget? _target;
  int _requestId = 0;

  SettingsSpotlightTarget? get target => _target;
  int get requestId => _requestId;

  void spotlightThinkingMode() {
    _target = SettingsSpotlightTarget.thinkingMode;
    _requestId++;
    notifyListeners();
  }
}
