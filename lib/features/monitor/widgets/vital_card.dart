import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/vitals_model.dart';
import '../../../core/theme/app_theme.dart';

class VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final VitalStatus status;

  const VitalCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case VitalStatus.critical: return AppColors.danger;
      case VitalStatus.warning:  return AppColors.warn;
      case VitalStatus.normal:   return AppColors.normal;
    }
  }

  String get _statusText {
    switch (status) {
      case VitalStatus.critical: return 'Critical';
      case VitalStatus.warning:  return 'Warning';
      case VitalStatus.normal:   return 'Normal';
    }
  }

  Color get _statusBg {
    switch (status) {
      case VitalStatus.critical: return AppColors.dangerBg;
      case VitalStatus.warning:  return AppColors.warnBg;
      case VitalStatus.normal:   return AppColors.normalBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red icon + label
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.red),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMid,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Large value
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              value,
              key: ValueKey(value),
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.textHigh,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            unit,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textLow,
            ),
          ),
          const SizedBox(height: 12),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _statusText,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
