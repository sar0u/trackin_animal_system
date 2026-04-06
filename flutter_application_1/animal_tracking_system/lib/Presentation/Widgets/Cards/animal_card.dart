import 'package:flutter/material.dart';

class AnimalCard extends StatelessWidget {
  final String name;
  final String breed;
  final String age;
  final String status;

  const AnimalCard({
    super.key,
    required this.name,
    required this.breed,
    required this.age,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.pets)),
        title: Text(name),
        subtitle: Text('$breed • $age'),
        trailing: Chip(
          label: Text(status),
          backgroundColor: status == 'Vérifié' ? Colors.green.shade100 : Colors.orange.shade100,
        ),
        onTap: () => Navigator.pushNamed(context, '/animal-passport'),
      ),
    );
  }
}