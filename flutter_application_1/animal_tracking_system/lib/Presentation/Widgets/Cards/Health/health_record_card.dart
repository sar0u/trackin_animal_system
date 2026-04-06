import 'package:flutter/material.dart';

class HealthRecordCard extends StatelessWidget {
  final String type;
  final String description;
  final String date;
  final String vet;

  const HealthRecordCard({
    super.key,
    required this.type,
    required this.description,
    required this.date,
    required this.vet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.health_and_safety, color: Colors.green),
        title: Text(type),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(date, style: const TextStyle(fontSize: 12)),
            Text(vet, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}