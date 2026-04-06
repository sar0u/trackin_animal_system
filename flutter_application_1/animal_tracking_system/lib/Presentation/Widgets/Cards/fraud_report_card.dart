import 'package:flutter/material.dart';

class FraudReportCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String status;

  const FraudReportCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.report_problem, color: Colors.red),
        title: Text(title),
        subtitle: Text(description),
        trailing: Chip(
          label: Text(status),
          backgroundColor: status == 'Résolu' ? Colors.green.shade100 : Colors.orange.shade100,
        ),
      ),
    );
  }
}