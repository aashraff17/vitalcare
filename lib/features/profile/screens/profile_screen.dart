import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/vitals_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final vitals = ref.watch(vitalsProvider);

    String roleName = 'Unknown';
    switch (authState.role) {
      case UserRole.patient:
        roleName = 'Patient';
        break;
      case UserRole.doctor:
        roleName = 'Doctor';
        break;
      case UserRole.nurse:
        roleName = 'Nurse';
        break;
      case UserRole.none:
        roleName = 'Guest';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Profile',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.redLight,
                  child: Icon(Icons.person, size: 40, color: AppColors.red),
                ),
                const SizedBox(height: 16),
                Text(
                  authState.email.split('@')[0].toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHigh,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMid,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authState.email,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMid,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(
                  vitals.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: vitals.isConnected ? AppColors.normal : AppColors.danger,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Status',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textHigh,
                        ),
                      ),
                      Text(
                        vitals.isConnected ? 'Connected to ESP32' : 'Disconnected',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
            label: Text(
              'Log Out',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
