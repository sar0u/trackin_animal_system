import '../../Core/Network/app_settings_service.dart';
import '../Models/app_settings_model.dart';

class AppSettingsRepository {
  final AppSettingsService _settingsService;

  AppSettingsRepository({required AppSettingsService settingsService})
      : _settingsService = settingsService;

  Future<void> saveLocale(String locale) async {
    await _settingsService.saveLocale(locale);
  }

  String getLocale() {
    return _settingsService.getLocale();
  }

  Future<void> saveDarkMode(bool isDark) async {
    await _settingsService.saveDarkMode(isDark);
  }

  bool getDarkMode() {
    return _settingsService.getDarkMode();
  }

  Future<void> clearCache() async {
    await _settingsService.clearCache();
  }

  AppSettingsModel getCurrentSettings() {
    return AppSettingsModel(
      locale: getLocale(),
      darkMode: getDarkMode(),
      notificationsEnabled: true,
      biometricEnabled: false,
    );
  }
}
