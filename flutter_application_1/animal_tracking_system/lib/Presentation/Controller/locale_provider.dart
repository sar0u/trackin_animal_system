import 'package:flutter/material.dart';
import '../../Core/Network/app_settings_service.dart';

class LocaleProvider extends ChangeNotifier {
  final AppSettingsService _settingsService;

  late Locale _selectedLocale;

  Locale get selectedLocale => _selectedLocale;

  LocaleProvider({required AppSettingsService settingsService})
      : _settingsService = settingsService {
    _selectedLocale = Locale(_settingsService.getLocale());
  }

  Future<void> setLocale(Locale locale) async {
    _selectedLocale = locale;
    await _settingsService.saveLocale(locale.languageCode);
    notifyListeners();
  }
}