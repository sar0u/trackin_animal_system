import 'package:flutter/material.dart';
import '../../Core/Network/app_settings_service.dart';

class AppThemeProvider extends ChangeNotifier {
  final AppSettingsService _settingsService;

  late bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;

  AppThemeProvider({required AppSettingsService settingsService})
      : _settingsService = settingsService {
    _isDarkMode = _settingsService.getDarkMode();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _settingsService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _settingsService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }
}