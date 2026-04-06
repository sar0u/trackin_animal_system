import 'package:flutter/material.dart';
import '../../../Core/Utils/app_translations.dart';
import '../../Widgets/Cards/animal_card.dart';

class AnimalsListScreen extends StatelessWidget {
  const AnimalsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate(context, 'animalList')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-animal'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AnimalCard(
            name: 'Bella',
            breed: 'Montbéliarde',
            age: '4.5 ans',
            status: 'Vérifié',
          ),
          AnimalCard(
            name: 'Max',
            breed: 'Angus',
            age: '3 ans',
            status: 'Vérifié',
          ),
          AnimalCard(
            name: 'Luna',
            breed: 'Merino',
            age: '2 ans',
            status: 'En Attente',
          ),
        ],
      ),
    );
  }
}