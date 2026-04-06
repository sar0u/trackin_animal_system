import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../Widgets/Cards/animal_card.dart';

class FarmDetailScreen extends StatelessWidget {
  const FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate(context, 'farmDetail'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nom: El-Wahat North', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Localisation: Oasis du Sud'),
            const Text('Capacité: 450 / 600'),
            const SizedBox(height: 16),
            const Text('Animaux Actuels:', style: TextStyle(fontWeight: FontWeight.bold)),
            const AnimalCard(name: 'Bella', breed: 'Montbéliarde', age: '4.5 ans', status: 'Actif'),
            const AnimalCard(name: 'Max', breed: 'Angus', age: '3 ans', status: 'Actif'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Voir Rapports d\'Inspection'),
            ),
          ],
        ),
      ),
    );
  }
}