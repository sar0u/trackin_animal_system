import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../../Widgets/Common/metric_card.dart';
import '../../Widgets/Common/section_title.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('National Command Center'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: cs.primary.withOpacity(.12),
              child: Icon(Icons.person_rounded, color: cs.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          MetricCard(
            title: 'Total Sheep Population',
            value: '4.2M',
            icon: Icons.pets_rounded,
            tint: cs.primary,
            delta: '+2.4%',
            onTap: () {},
          ).animate().fadeIn(duration: 240.ms).slideY(begin: .08, end: 0),

          MetricCard(
            title: 'Total Cattle Population',
            value: '1.8M',
            icon: Icons.agriculture_rounded,
            tint: AppColors.infoBlue,
            delta: '-0.8%',
            onTap: () {},
          ).animate().fadeIn(duration: 260.ms).slideY(begin: .08, end: 0),

          MetricCard(
            title: 'Total Camel Population',
            value: '850K',
            icon: Icons.terrain_rounded,
            tint: AppColors.secondaryOlive,
            delta: 'Stable',
            onTap: () {},
          ).animate().fadeIn(duration: 280.ms).slideY(begin: .08, end: 0),

          const SizedBox(height: 6),

          _AlertBanner(
            color: AppColors.dangerRed,
            icon: Icons.gpp_bad_rounded,
            title: '12 Active Fraud Alerts',
            subtitle: 'Suspicious movement detected in Souk Ahras sector.',
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: .08, end: 0),

          _AlertBanner(
            color: AppColors.warningOrange,
            icon: Icons.lock_clock_rounded,
            title: '04 Recent Quarantines',
            subtitle: 'LSD outbreak isolation enforced in Sétif province.',
            onTap: () {},
          ).animate().fadeIn(duration: 320.ms).slideY(begin: .08, end: 0),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Historical Population Comparison',
                    trailing: Text('2014 - 2024', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 1.6),
                              FlSpot(1, 2.0),
                              FlSpot(2, 1.8),
                              FlSpot(3, 2.6),
                              FlSpot(4, 2.2),
                              FlSpot(5, 3.0),
                            ],
                            isCurved: true,
                            barWidth: 4,
                            color: cs.primary,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: cs.primary.withOpacity(.12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/map'),
                          icon: const Icon(Icons.map_rounded),
                          label: const Text('Open Live Map'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/reports'),
                          icon: const Icon(Icons.description_rounded),
                          label: const Text('Reports'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 340.ms).slideY(begin: .08, end: 0),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'Disease Surveillance'),
                  const SizedBox(height: 10),
                  _RiskRow(title: 'FMD Risk - North', status: 'High Risk', color: AppColors.dangerRed),
                  _RiskRow(title: 'PPR - Central Steppe', status: 'Monitoring', color: AppColors.warningOrange),
                  _RiskRow(title: 'Bluetongue - Coastal', status: 'Cleared', color: AppColors.successGreen),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 360.ms).slideY(begin: .08, end: 0),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AlertBanner({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(.22)),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  final String title;
  final String status;
  final Color color;

  const _RiskRow({required this.title, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}