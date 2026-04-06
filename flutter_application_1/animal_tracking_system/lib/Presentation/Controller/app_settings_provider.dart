import 'package:flutter/material.dart';
import '../../Data/Models/app_settings_model.dart';
import '../../Data/Repositories/app_settings_repository.dart';

class AppSettingsProvider extends ChangeNotifier {
  final AppSettingsRepository _repository;
  late AppSettingsModel _settings;

  AppSettingsProvider({required AppSettingsRepository repository}) : _repository = repository {
    _settings = _repository.getCurrentSettings();
  }

  AppSettingsModel get settings => _settings;

  void updateLocale(String locale) {
    _settings = AppSettingsModel(
      locale: locale,
      darkMode: _settings.darkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      biometricEnabled: _settings.biometricEnabled,
    );
    _repository.saveLocale(locale);
    notifyListeners();
  }

  void updateDarkMode(bool isDark) {
    _settings = AppSettingsModel(
      locale: _settings.locale,
      darkMode: isDark,
      notificationsEnabled: _settings.notificationsEnabled,
      biometricEnabled: _settings.biometricEnabled,
    );
    _repository.saveDarkMode(isDark);
    notifyListeners();
  }

  void clearCache() {
    _repository.clearCache();
    notifyListeners();
  }
}