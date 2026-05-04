class ApiConstants {
  static const String baseUrl = 'http://192.168.100.12:8080/api/v1'; // Android Emulator
  // static const String baseUrl = 'http://192.168.x.x:8080/api/v1'; // Vrai téléphone

  // Auth
  static const String login = '/auth/login';

  // Animaux
  static const String animalByRfid = '/animals/rfid/';

  // Fermier
  static const String fermierHistory = '/fermier/animals/rfid/';

  // Vétérinaire
  static const String veterinaireHealth = '/veterinaire/animals/rfid/';
  static const String addVaccination = '/veterinaire/animals/rfid/';
  static const String addHealthRecord = '/veterinaire/animals/rfid/';

  // Contrôleur
  static const String controleurCheck = '/controleur/check';
  static const String controleurAnomalies = '/controleur/anomalies';

  // Constat
  static const String constats = '/constats';

  // Upload fichiers
  static const String uploadPhoto = '/files/upload/photo';
  static const String uploadAudio = '/files/upload/audio';

  static const String createAnimal = '/animals/create';
}

