import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class AlertModel {
  final String title;
  final DateTime time;
  final Color color;
  final IconData icon;
  final String detail;

  const AlertModel({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
    required this.detail,
  });
}

class AlertsNotifier extends StateNotifier<List<AlertModel>> {
  AlertsNotifier() : super([
    AlertModel(
      title: 'System Initialized',
      time: DateTime.now().subtract(const Duration(minutes: 60)),
      color: AppColors.normal,
      icon: Icons.check_circle_outline,
      detail: 'Monitoring system connected and active',
    ),
  ]);

  void addAlert(AlertModel alert) {
    state = [alert, ...state];
  }
}

final alertsProvider = StateNotifierProvider<AlertsNotifier, List<AlertModel>>((ref) {
  return AlertsNotifier();
});
