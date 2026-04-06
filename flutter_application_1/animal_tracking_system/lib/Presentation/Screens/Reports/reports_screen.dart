import 'package:flutter/material.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../../../Core/Services/mock_data_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String filterType = 'All';

  @override
  Widget build(BuildContext context) {
    final allReports = MockDataService.getSampleReports();

    var filteredReports = allReports;
    if (filterType != 'All') {
      filteredReports = allReports.where((r) => r['type'] == filterType).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('National Command Center'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune_rounded),
            onSelected: (val) => setState(() => filterType = val),
            itemBuilder: (_) => ['All', 'Fraud', 'Health'].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredReports.length,
        itemBuilder: (ctx, index) {
          final report = filteredReports[index];
          final severity = report['severity'] as String;

          Color bg = Colors.grey.shade50;
          Color accent = Colors.blue;
          IconData icon = Icons.info_outline;
          String badgeColorName = '';

          if (severity == 'High') {
            bg = AppColors.dangerRed.withOpacity(0.05);
            accent = AppColors.dangerRed;
            icon = Icons.warning_amber_rounded;
            badgeColorName = 'URGENT';
          } else if (report['type'] == 'Health') {
            bg = AppColors.warningOrange.withOpacity(0.05);
            accent = AppColors.warningOrange;
            icon = Icons.local_hospital;
            badgeColorName = 'Risk';
          }

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: bg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  report['title'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (severity == 'High') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerRed,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('URGENT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ]
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(report['location'] as String, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}