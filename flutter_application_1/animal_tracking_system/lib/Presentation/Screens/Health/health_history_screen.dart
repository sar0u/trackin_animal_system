import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../Widgets/Cards/Health/health_record_card.dart';


class HealthHistoryScreen extends StatelessWidget {
  const HealthHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HealthRecordCard(
            type: 'Vaccination FMD',
            description: 'Dose administrée',
            date: '12/03/2024',
            vet: 'Dr. Ahmed Benalia',
          ),
          HealthRecordCard(
            type: 'Contrôle Santé',
            description: 'Examen général',
            date: '15/05/2024',
            vet: 'Dr. Fatima Zohra',
          ),
        ],
      ),
    );
  }
}