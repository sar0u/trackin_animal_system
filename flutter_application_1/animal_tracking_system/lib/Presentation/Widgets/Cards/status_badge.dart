import 'package:flutter/material.dart';
import '../../../Core/Constatnts/app_colors.dart';
import '../../../Core/Constatnts/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isActive;

  const StatusBadge({
    super.key,
    required this.status,
    this.isActive = true,
  });

  Color get _statusColor {
    if (status.toLowerCase().contains('actif') ||
        status.toLowerCase().contains('vérifié') ||
        status.toLowerCase().contains('healthy')) {
      return AppColors.successGreen;
    } else if (status.toLowerCase().contains('attente') ||
        status.toLowerCase().contains('monitoring')) {
      return AppColors.warningOrange;
    } else {
      return AppColors.dangerRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelMedium.copyWith(
          color: _statusColor,
          fontSize: 12,
        ),
      ),
    );
  }
}