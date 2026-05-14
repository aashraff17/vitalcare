import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/vitals_model.dart';
import '../../../core/theme/app_theme.dart';

class RiskStatusCard extends StatelessWidget {
  final RiskLevel riskLevel;
  final double probability;
  final bool isLoading;
  final bool apiOffline;
  final bool showAnalytics;

  const RiskStatusCard({
    super.key,
    required this.riskLevel,
    required this.probability,
    this.isLoading = false,
    this.apiOffline = false,
    this.showAnalytics = false,
  });

  Color get _color {
    switch (riskLevel) {
      case RiskLevel.critical: return AppColors.danger;
      case RiskLevel.warning:  return AppColors.warn;
      case RiskLevel.low:      return AppColors.normal;
    }
  }

  Color get _bg {
    switch (riskLevel) {
      case RiskLevel.critical: return AppColors.dangerBg;
      case RiskLevel.warning:  return AppColors.warnBg;
      case RiskLevel.low:      return AppColors.normalBg;
    }
  }

  String get _label {
    switch (riskLevel) {
      case RiskLevel.critical: return 'Critical Risk';
      case RiskLevel.warning:  return 'Warning';
      case RiskLevel.low:      return 'Low Risk';
    }
  }

  String get _description {
    switch (riskLevel) {
      case RiskLevel.critical: return 'Patient requires immediate medical attention.';
      case RiskLevel.warning:  return 'Vitals outside normal range. Monitor closely.';
      case RiskLevel.low:      return 'All vitals are within normal range.';
    }
  }

  IconData get _icon {
    switch (riskLevel) {
      case RiskLevel.critical: return Icons.warning_rounded;
      case RiskLevel.warning:  return Icons.info_outline_rounded;
      case RiskLevel.low:      return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // Header
          Row(
            children: [
              Text(
                'AI Risk Assessment',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMid,
                  letterSpacing: 0.2,
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textLow,
                  ),
                ),
              ],
              if (apiOffline) ...[
                const SizedBox(width: 8),
                Text(
                  'API Offline',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warn,
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_icon, size: 13, color: _color),
                    const SizedBox(width: 5),
                    Text(
                      _label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Opacity(
            opacity: isLoading ? 0.55 : 1,
            child: Text(
              _description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMid,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Probability bar
          if (showAnalytics) ...[
            Opacity(
              opacity: isLoading ? 0.55 : 1,
              child: Row(
                children: [
                  Text(
                    'Risk probability',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textLow,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isLoading ? '…' : '${(probability * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: isLoading
                  ? const LinearProgressIndicator(
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textLow),
                      minHeight: 5,
                    )
                  : TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: probability),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(_color),
                        minHeight: 5,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
