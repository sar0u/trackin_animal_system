class AppSettingsModel {
  final String locale;
  final bool darkMode;
  final bool notificationsEnabled;
  final bool biometricEnabled;

  AppSettingsModel({
    required this.locale,
    required this.darkMode,
    required this.notificationsEnabled,
    required this.biometricEnabled,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      locale: json['locale'],
      darkMode: json['dark_mode'],
      notificationsEnabled: json['notifications_enabled'],
      biometricEnabled: json['biometric_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
      'biometric_enabled': biometricEnabled,
    };
  }
}