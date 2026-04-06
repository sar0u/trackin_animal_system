class AppSettings {
  final String languageCode; // possible values: 'en', 'fr', 'ar'
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool soundsEnabled;
  final bool biometricEnabled;
  final bool autoSyncEnabled;
  final bool locationTrackingEnabled;

  AppSettings({
    required this.languageCode,
    required this.darkModeEnabled,
    required this.notificationsEnabled,
    required this.soundsEnabled,
    required this.biometricEnabled,
    required this.autoSyncEnabled,
    required this.locationTrackingEnabled,
  });

  // Used to update single values without rewriting entire object
  AppSettings copyWith({
    String? languageCode,
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? soundsEnabled,
    bool? biometricEnabled,
    bool? autoSyncEnabled,
    bool? locationTrackingEnabled,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      locationTrackingEnabled: locationTrackingEnabled ?? this.locationTrackingEnabled,
    );
  }

  // Default values for first app launch
  factory AppSettings.initial() {
    return AppSettings(
      languageCode: 'fr', // set your default language here
      darkModeEnabled: false,
      notificationsEnabled: true,
      soundsEnabled: true,
      biometricEnabled: false,
      autoSyncEnabled: true,
      locationTrackingEnabled: true,
    );
  }
}