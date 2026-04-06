import '../../Data/Models/animal_model.dart';


class MockDataService {

  /// Retourne une liste d'animaux basée sur AnimalModel (Frontend Mock)
  static List<AnimalModel> getSampleAnimals() {
    return [
      AnimalModel(
        id: 'ANM-001',
        name: 'Bella',
        breed: 'Ouled Djellal',
        age: 2.5,
        weight: 75.0,
        status: 'Healthy',
        farmId: 'FRM-001',
        rfid: '824 000 129 384 556',
        birthDate: DateTime(2021, 3, 12),
        lastHealthCheck: DateTime.now().subtract(const Duration(hours: 2)),
        imageUrl: '', // URL vers image réelle si besoin
        isVerified: true,
      ),
      AnimalModel(
        id: 'ANM-002',
        name: 'Maximus',
        breed: 'Montbéliarde',
        age: 4.0,
        weight: 120.0,
        status: 'Suspicious',
        farmId: 'FRM-002',
        rfid: '824 000 555 111 222',
        birthDate: DateTime(2020, 1, 15),
        lastHealthCheck: DateTime.now().subtract(const Duration(days: 15)),
        imageUrl: '',
        isVerified: false,
      ),
      AnimalModel(
        id: 'ANM-003',
        name: 'Luna',
        breed: 'Angus',
        age: 1.5,
        weight: 90.0,
        status: 'Quarantine',
        farmId: 'FRM-001',
        rfid: '824 000 999 888 777',
        birthDate: DateTime(2022, 8, 10),
        lastHealthCheck: DateTime.now().subtract(const Duration(minutes: 45)),
        imageUrl: '',
        isVerified: true,
      ),
    ];
  }

  /// Retourne un ensemble de rapports/alertes pour la page Rapports
  static List<Map<String, dynamic>> getSampleReports() {
    return [
      {
        'id': 'REP-001',
        'title': 'Fraud Detected: Illegal Sale',
        'type': 'Fraud',
        'location': 'Tiaret (W.14)',
        'date': DateTime.now().subtract(const Duration(minutes: 30)),
        'status': 'Pending', // Pending, Resolved, Urgent
        'severity': 'High',
      },
      {
        'id': 'REP-002',
        'title': 'Health Alert: FMD Symptoms',
        'type': 'Health',
        'location': 'Souk Ahras (W.40)',
        'date': DateTime.now().subtract(const Duration(hours: 5)),
        'status': 'Investigating',
        'severity': 'Medium',
      },
      {
        'id': 'REP-003',
        'title': 'Transport Deviation Detected',
        'type': 'Fraud',
        'location': 'Alger (W.16)',
        'date': DateTime.now().subtract(const Duration(hours: 12)),
        'status': 'Resolved',
        'severity': 'Low',
      },
    ];
  }
}