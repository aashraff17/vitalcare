import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vitals_model.dart';
import '../services/vitals_api_service.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'alerts_provider.dart';

// ─── Chart history ─────────────────────────────────────────────────────────────
class ChartHistory {
  final List<double> heartRate;
  final List<double> temperature;
  static const int maxPoints = 15; // keep last 15 readings

  const ChartHistory({
    required this.heartRate,
    required this.temperature,
  });

  ChartHistory push(double hr, double temp) {
    final hrList  = [...heartRate,   hr  ];
    final tmpList = [...temperature, temp];
    final newHr   = hrList.length  > maxPoints ? hrList.sublist(hrList.length   - maxPoints) : hrList;
    final newTemp = tmpList.length > maxPoints ? tmpList.sublist(tmpList.length - maxPoints) : tmpList;
    return ChartHistory(heartRate: newHr, temperature: newTemp);
  }

  static ChartHistory get initial => ChartHistory(
    heartRate:   List.filled(15, 82.0),
    temperature: List.filled(15, 36.8),
  );
}

// ─── Risk calculator ───────────────────────────────────────────────────────────
RiskLevel _calculateRisk(double hr, double spo2, double temp) {
  // Critical conditions (any one is enough)
  if (spo2 < 90 || hr > 120 || temp > 39.0) return RiskLevel.critical;
  // Warning conditions
  if (spo2 < 94 || hr > 100 || temp > 38.5) return RiskLevel.warning;
  return RiskLevel.low;
}

double _riskProbability(RiskLevel level, double hr, double spo2, double temp) {
  switch (level) {
    case RiskLevel.critical:
      // Scale within critical band: 0.80 – 1.00
      return (0.80 + (hr - 120).clamp(0, 30) / 150).clamp(0.80, 1.0);
    case RiskLevel.warning:
      // Scale within warning band: 0.40 – 0.79
      return (0.40 + (100 - spo2).clamp(0, 4) / 10).clamp(0.40, 0.79);
    case RiskLevel.low:
      // Scale within low band: 0.03 – 0.39
      return (0.03 + (hr - 75).clamp(0, 25) / 250).clamp(0.03, 0.39);
  }
}

// ─── Vitals Notifier ──────────────────────────────────────────────────────────
class VitalsNotifier extends StateNotifier<VitalsModel> {
  final Ref ref;
  VitalsNotifier(this.ref) : super(VitalsModel.initial) {
    _startSimulation();
    scheduleMicrotask(() {
      if (!_disposed) _requestRiskPredict();
    });
  }

  Timer? _timer;
  final _rng = Random();
  final VitalsApiService _api = VitalsApiService();
  int _predictSeq = 0;
  bool _disposed = false;

  // Realistic baseline to drift toward after simulate critical
  static const double _baseHr   = 82.0;
  static const double _baseSpo2 = 97.5;
  static const double _baseTemp = 36.8;
  static const double _baseRr   = 18.0;

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
  }

  void _tick() {
    // Small random walk — gently pulled back toward baseline
    double newHr = state.heartRate
        + (_rng.nextDouble() * 3 - 1.5)            // ±1.5 step
        + (_baseHr - state.heartRate) * 0.05;       // 5% pull toward baseline
    double newSpo2 = state.spo2
        + (_rng.nextDouble() * 0.4 - 0.2)
        + (_baseSpo2 - state.spo2) * 0.05;
    double newTemp = state.temperature
        + (_rng.nextDouble() * 0.06 - 0.03)
        + (_baseTemp - state.temperature) * 0.05;
    double newRr = state.respiratoryRate
        + (_rng.nextDouble() * 1.0 - 0.5)
        + (_baseRr - state.respiratoryRate) * 0.05;

    // Clamp to realistic operating ranges
    newHr   = newHr.clamp(75.0, 90.0);
    newSpo2 = newSpo2.clamp(95.0, 99.0);
    newTemp = newTemp.clamp(36.5, 37.3);
    newRr   = newRr.clamp(16.0, 20.0);

    _applyValues(newHr, newSpo2, newTemp, newRr);
  }

  void _applyValues(double hr, double spo2, double temp, double rr) {
    state = state.copyWith(
      heartRate:       double.parse(hr.toStringAsFixed(0)),
      spo2:            double.parse(spo2.toStringAsFixed(1)),
      temperature:     double.parse(temp.toStringAsFixed(1)),
      respiratoryRate: double.parse(rr.toStringAsFixed(0)),
      lastUpdated:     DateTime.now(),
    );
    _requestRiskPredict();
  }

  Future<void> _requestRiskPredict() async {
    final seq = ++_predictSeq;
    final hr = state.heartRate;
    final spo2 = state.spo2;
    final temp = state.temperature;
    final rr = state.respiratoryRate;

    state = state.copyWith(riskPredictLoading: true);

    try {
      final result = await _api.predictRisk(
        heartRate: hr,
        oxygenSaturation: spo2,
        temperature: temp,
        respiratoryRate: rr,
      );
      if (_disposed || seq != _predictSeq) return;

      state = state.copyWith(
        riskLevel: result.riskLevel,
        riskProbability: result.riskProbability,
        riskApiOnline: true,
        riskPredictLoading: false,
      );
    } on Object catch (_) {
      if (_disposed || seq != _predictSeq) return;

      final risk = _calculateRisk(hr, spo2, temp);
      state = state.copyWith(
        riskLevel: risk,
        riskProbability: _riskProbability(risk, hr, spo2, temp),
        riskApiOnline: false,
        riskPredictLoading: false,
      );
    }
  }

  /// Demo button — inject critical values; timer will slowly recover.
  void simulateCritical() {
    _applyValues(
      128, // HR critically high
      86,  // SpO2 critically low
      39.6, // Fever
      28,  // RR elevated
    );
    
    // Trigger critical alert dynamically
    ref.read(alertsProvider.notifier).addAlert(
      AlertModel(
        title: 'Critical Vitals Detected',
        time: DateTime.now(),
        color: AppColors.danger,
        icon: Icons.warning_rounded,
        detail: 'Patient triggered critical vital thresholds',
      ),
    );
  }

  /// Swap in real API data instead of simulation.
  void updateFromApi(VitalsModel fresh) {
    state = fresh;
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}

// ─── Chart History Notifier ───────────────────────────────────────────────────
class ChartHistoryNotifier extends StateNotifier<ChartHistory> {
  ChartHistoryNotifier(Ref ref) : super(ChartHistory.initial) {
    ref.listen<VitalsModel>(vitalsProvider, (_, next) {
      state = state.push(next.heartRate, next.temperature);
    });
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final vitalsProvider =
    StateNotifierProvider<VitalsNotifier, VitalsModel>((ref) {
  return VitalsNotifier(ref);
});

final chartHistoryProvider =
    StateNotifierProvider<ChartHistoryNotifier, ChartHistory>((ref) {
  return ChartHistoryNotifier(ref);
});
