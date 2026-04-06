class AppConstants {
  static const String appName = 'TraceDZ';
  static const String baseUrl = 'https://api.tracedz.dz';
  static const String apiKey = 'TRACEDZ-API-KEY-2024';
  static const int timeout = 30;
  static const String defaultLocale = 'fr';
  static const bool defaultDarkMode = false;

  // Routes API
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String animalsEndpoint = '/animals';
  static const String farmsEndpoint = '/farms';
  static const String healthEndpoint = '/health';
  static const String reportsEndpoint = '/reports';

  // Assets
  static const String logo = 'assets/images/logo.png';
  static const String placeholderAnimal = 'assets/images/animal_placeholder.png';
  static const String placeholderFarm = 'assets/images/farm_placeholder.png';
}