import 'package:shared_preferences/shared_preferences.dart';
import '../Constatnts/app_constatns.dart';

class AppSettingsService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Langue
  Future<void> saveLocale(String locale) async {
    await _prefs.setString('locale', locale);
  }

  String getLocale() {
    return _prefs.getString('locale') ?? AppConstants.defaultLocale;
  }

  // Mode Sombre
  Future<void> saveDarkMode(bool isDark) async {
    await _prefs.setBool('darkMode', isDark);
  }

  bool getDarkMode() {
    return _prefs.getBool('darkMode') ?? AppConstants.defaultDarkMode;
  }

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString('token', token);
  }

  String? getToken() {
    return _prefs.getString('token');
  }

  // Nettoyer Cache
  Future<void> clearCache() async {
    await _prefs.clear();
  }
}