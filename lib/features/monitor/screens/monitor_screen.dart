import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/vitals_model.dart';
import '../../../core/providers/vitals_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/vital_card.dart';
import '../widgets/risk_status_card.dart';
import '../widgets/vitals_chart.dart';
import '../widgets/emergency_banner.dart';

class MonitorScreen extends ConsumerStatefulWidget {
  const MonitorScreen({super.key});

  @override
  ConsumerState<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends ConsumerState<MonitorScreen> {
  @override
  void initState() {
    super.initState();
    // Dark icons on light status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final vitals  = ref.watch(vitalsProvider);
    final history = ref.watch(chartHistoryProvider);
    final role    = ref.watch(authProvider).role;

    final isDoctor = role == UserRole.doctor;
    final isPatient = role == UserRole.patient;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (white, red logo) ────────────────────────────────
            _Header(vitals: vitals),
            const Divider(height: 1, thickness: 1, color: AppColors.divider),

            // ── Patient strip ───────────────────────────────────────────
            _PatientStrip(vitals: vitals, role: role),
            const Divider(height: 1, thickness: 1, color: AppColors.divider),

            // ── Scrollable body ─────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [

                  // Emergency banner (critical only)
                  if (vitals.isEmergency) ...[
                    const EmergencyBanner(),
                    const SizedBox(height: 14),
                  ],

                  // ── Vitals grid 2 × 2 ─────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: VitalCard(
                          label: 'Heart Rate',
                          value: vitals.heartRate.toStringAsFixed(0),
                          unit: 'BPM',
                          icon: Icons.favorite_border_rounded,
                          status: vitals.hrStatus,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: VitalCard(
                          label: 'SpO2',
                          value: vitals.spo2.toStringAsFixed(1),
                          unit: '% Sat.',
                          icon: Icons.bubble_chart_outlined,
                          status: vitals.spo2Status,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: VitalCard(
                          label: 'Temperature',
                          value: vitals.temperature.toStringAsFixed(1),
                          unit: '°C',
                          icon: Icons.thermostat_outlined,
                          status: vitals.tempStatus,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: VitalCard(
                          label: 'Resp. Rate',
                          value: vitals.respiratoryRate.toStringAsFixed(0),
                          unit: 'br / min',
                          icon: Icons.air_outlined,
                          status: vitals.rrStatus,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── AI Risk ────────────────────────────────────────────
                  RiskStatusCard(
                    riskLevel: vitals.riskLevel,
                    probability: vitals.riskProbability,
                    isLoading: vitals.riskPredictLoading,
                    apiOffline: !vitals.riskApiOnline,
                    showAnalytics: isDoctor, // Hide detailed percentage for non-doctors
                  ),

                  const SizedBox(height: 16),

                  // ── Charts (Hide advanced charts for Patient, show basic for Nurse, detailed for Doctor)
                  if (!isPatient) ...[
                    Text(
                      isDoctor ? 'Detailed Trend Analytics' : 'Trend Charts',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMid,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    VitalsChart(
                      title: 'Heart Rate',
                      unit: 'BPM',
                      dataPoints: history.heartRate,
                      lineColor: AppColors.red,
                      minY: 40,
                      maxY: 140,
                      isDetailed: isDoctor,
                    ),
                    const SizedBox(height: 10),
                    VitalsChart(
                      title: 'Temperature',
                      unit: '°C',
                      dataPoints: history.temperature,
                      lineColor: AppColors.warn,
                      minY: 35.0,
                      maxY: 41.0,
                      isDetailed: isDoctor,
                    ),
                  ] else ...[
                    // Simple basic chart indicator for patient
                    Text(
                      'Basic Trend',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMid,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    VitalsChart(
                      title: 'Heart Rate',
                      unit: 'BPM',
                      dataPoints: history.heartRate,
                      lineColor: AppColors.red,
                      minY: 40,
                      maxY: 140,
                      isDetailed: false,
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),

                  // ── Demo control ───────────────────────────────────────
                  const _SimulateCriticalButton(),

                  const SizedBox(height: 8),
                ],

              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VitalsModel vitals;
  const _Header({required this.vitals});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,          // white header
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Red icon box
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.monitor_heart_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VitalCare AI',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHigh,
                ),
              ),
              Text(
                'Patient Monitor',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textMid,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Connection status
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: vitals.isConnected
                      ? AppColors.normal
                      : AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                vitals.isConnected ? 'Connected' : 'Offline',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: vitals.isConnected
                      ? AppColors.normal
                      : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Patient strip ─────────────────────────────────────────────────────────────
class _PatientStrip extends StatelessWidget {
  final VitalsModel vitals;
  final UserRole role;
  const _PatientStrip({required this.vitals, required this.role});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss').format(vitals.lastUpdated);

    return Container(
      color: AppColors.surface,          // white
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.redLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Text(
                'AH',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role == UserRole.patient ? 'Your Health Profile' : 'Ahmed Hassan',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHigh,
                  ),
                ),
                Text(
                  role == UserRole.patient ? 'Active Monitoring' : 'ICU · Bed A-01 · 47 years',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMid,
                  ),
                ),
                if (role == UserRole.doctor) ...[
                  const SizedBox(height: 2),
                  Text(
                    'History: Hypertension, Type 2 Diabetes',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warn,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Last updated',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.textLow,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeStr,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHigh,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Simulate Critical demo button ─────────────────────────────────────────────
class _SimulateCriticalButton extends ConsumerWidget {
  // ignore: unused_element
  const _SimulateCriticalButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () =>
            ref.read(vitalsProvider.notifier).simulateCritical(),
        icon: const Icon(Icons.warning_amber_rounded, size: 16),
        label: Text(
          'Demo: Simulate Critical',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
