import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/alerts_provider.dart';
import '../../../core/providers/auth_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role;
    final isPatient = role == UserRole.patient;
    final isDoctor = role == UserRole.doctor;

    final mockAlerts = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          isPatient ? 'Your Notifications' : 'Recent Alerts',
          style: GoogleFonts.inter(
            color: AppColors.textHigh,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.divider, height: 1),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: isPatient ? 2 : mockAlerts.length, // Show fewer alerts for patient
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alert = mockAlerts[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: alert.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    alert.icon,
                    color: alert.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textHigh,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isPatient)
                        Text(
                          'Awaiting nurse review',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMid,
                          ),
                        )
                      else ...[
                        Text(
                          DateFormat('MMM dd, yyyy - HH:mm').format(alert.time),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMid,
                          ),
                        ),
                        if (isDoctor) ...[
                          const SizedBox(height: 4),
                          Text(
                            alert.detail,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.warn,
                            ),
                          ),
                        ],
                      ]
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
