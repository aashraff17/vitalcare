import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go('/home/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'VitalCare AI',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textHigh,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Patient Monitoring System',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMid,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.red),
          ],
        ),
      ),
    );
  }
}
