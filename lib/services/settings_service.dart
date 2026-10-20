import 'package:flutter/material.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  ThemeMode _themeMode = ThemeMode.light;
  double _textScaleFactor = 1.10;

  ThemeMode get themeMode => _themeMode;
  double get textScaleFactor => _textScaleFactor;

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void updateTextScale(double scale) {
    _textScaleFactor = scale.clamp(0.85, 1.45); // Limit scale range
    notifyListeners();
  }
}
