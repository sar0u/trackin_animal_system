import 'package:flutter/material.dart';
import '../../../../Core/Utils/app_translations.dart';
import '../../../../Data/Models/health_record_model.dart';
import 'health_record_card.dart';

class HealthHistoryScreen extends StatelessWidget {
  const HealthHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Données de test (à remplacer par les données réelles)
    final List<HealthRecordModel> records = [
      HealthRecordModel(
        id: '1',
        animalId: 'DZ-24-99812',
        type: 'Vaccination FMD',
        description: 'Dose administrée',
        date: DateTime(2024, 3, 12),
        vetId: 'VET-001',
        vetName: 'Dr. Ahmed Benalia',
        notes: 'Aucun effet secondaire',
        isVerified: true,
      ),
      HealthRecordModel(
        id: '2',
        animalId: 'DZ-24-99812',
        type: 'Contrôle Santé',
        description: 'Examen général',
        date: DateTime(2024, 5, 15),
        vetId: 'VET-002',
        vetName: 'Dr. Fatima Zohra',
        notes: 'Animal en bonne santé',
        isVerified: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate(context, 'healthHistory')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-health-record'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return HealthRecordCard(
            type: record.type,
            description: record.description,
            date: '${record.date.day}/${record.date.month}/${record.date.year}',
            vet: record.vetName,
          );
        },
      ),
    );
  }
}