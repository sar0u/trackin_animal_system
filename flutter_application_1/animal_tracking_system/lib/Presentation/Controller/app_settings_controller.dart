import 'package:flutter/material.dart';
import '../../Core/Services/app_settings_service.dart';

class AppSettingsController extends ChangeNotifier {
  final AppSettingsService _service;

  bool _isDarkMode = false;
  String _languageCode = 'en';
  bool _isLoaded = false;

  AppSettingsController(this._service);

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  bool get loaded => _isLoaded;

  Future<void> load() async {
    _isDarkMode = await _service.getDarkMode();
    _languageCode = await _service.getLanguageCode();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await _service.setDarkMode(value);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    await _service.setLanguageCode(code);
    notifyListeners();
  }
}