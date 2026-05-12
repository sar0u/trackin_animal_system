import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/health_alert_provider.dart';

class HealthAlertScreen extends StatefulWidget {
  const HealthAlertScreen({super.key});

  @override
  State<HealthAlertScreen> createState() => _HealthAlertScreenState();
}

class _HealthAlertScreenState extends State<HealthAlertScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthAlertProvider>(context, listen: false)
          .loadAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthAlertProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Alertes Sanitaires"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadAlerts(),
        child: provider.isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        )
            : provider.alerts.isEmpty
            ? const Center(
          child: Text(
            "Aucune alerte en attente",
            style: TextStyle(color: AppColors.textGrey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.alerts.length,
          itemBuilder: (context, index) {
            final alert = provider.alerts[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  _iconForSeverity(alert.severity),
                  color: _colorForSeverity(alert.severity),
                ),
                title: Text(
                  alert.alertType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${alert.message ?? ''}\nDate limite: ${alert.dueDate}",
                ),
                isThreeLine: true,
                trailing: alert.isResolved
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                        onPressed: () => provider.resolveAlert(alert.id),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _iconForSeverity(String? severity) {
    switch (severity) {
      case 'CRITICAL':
        return Icons.warning;
      case 'WARNING':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorForSeverity(String? severity) {
    switch (severity) {
      case 'CRITICAL':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}