import 'package:flutter/material.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../Common/app_badge.dart';

class FarmCard extends StatelessWidget {
  final String name;
  final String location;
  final String capacity; // "450 / 600"
  final String status;   // "Verified" / "Suspect" / "Actif"
  final double occupancyPercent; // 0..100
  final VoidCallback onTap;

  const FarmCard({
    super.key,
    required this.name,
    required this.location,
    required this.capacity,
    required this.status,
    required this.occupancyPercent,
    required this.onTap,
  });

  Color get _statusColor {
    final s = status.toLowerCase();
    if (s.contains('ver')) return AppColors.successGreen;
    if (s.contains('sus')) return AppColors.warningOrange;
    return AppColors.infoBlue;
  }

  IconData get _statusIcon {
    final s = status.toLowerCase();
    if (s.contains('ver')) return Icons.verified;
    if (s.contains('sus')) return Icons.warning_amber_rounded;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.primary.withOpacity(.14)),
                    ),
                    child: Icon(Icons.home_work_rounded, color: cs.primary),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),
                  AppBadge(text: status, color: _statusColor),
                ],
              ),

              const SizedBox(height: 12),

              // Capacity row
              Row(
                children: [
                  Icon(Icons.groups_2_outlined, size: 18, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Capacité: $capacity',
                    style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Icon(_statusIcon, color: _statusColor, size: 20),
                ],
              ),

              const SizedBox(height: 10),

              // Progress
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (occupancyPercent / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: cs.primary.withOpacity(.10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    occupancyPercent >= 90 ? AppColors.dangerRed : cs.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Occupation: ${occupancyPercent.toStringAsFixed(0)}%',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}