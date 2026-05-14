enum VitalStatus { normal, warning, critical }
enum RiskLevel  { low, warning, critical }

class VitalsModel {
  final double heartRate;        // BPM
  final double spo2;             // %
  final double temperature;      // °C
  final double respiratoryRate;  // breaths/min
  final RiskLevel riskLevel;
  final double riskProbability;  // 0.0 – 1.0
  final bool isConnected;
  final bool riskApiOnline;
  final bool riskPredictLoading;
  final DateTime lastUpdated;

  const VitalsModel({
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.respiratoryRate,
    required this.riskLevel,
    required this.riskProbability,
    required this.isConnected,
    this.riskApiOnline = true,
    this.riskPredictLoading = false,
    required this.lastUpdated,
  });

  // ─── Status helpers ────────────────────────────────────────────────────────
  VitalStatus get hrStatus {
    if (heartRate < 40 || heartRate > 130) return VitalStatus.critical;
    if (heartRate < 55 || heartRate > 100) return VitalStatus.warning;
    return VitalStatus.normal;
  }

  VitalStatus get spo2Status {
    if (spo2 < 90) return VitalStatus.critical;
    if (spo2 < 95) return VitalStatus.warning;
    return VitalStatus.normal;
  }

  VitalStatus get tempStatus {
    if (temperature > 39.5 || temperature < 35.0) return VitalStatus.critical;
    if (temperature > 38.0 || temperature < 36.0) return VitalStatus.warning;
    return VitalStatus.normal;
  }

  VitalStatus get rrStatus {
    if (respiratoryRate > 30 || respiratoryRate < 8)  return VitalStatus.critical;
    if (respiratoryRate > 24 || respiratoryRate < 12) return VitalStatus.warning;
    return VitalStatus.normal;
  }

  bool get isEmergency => riskLevel == RiskLevel.critical;

  // ─── Copy-with ─────────────────────────────────────────────────────────────
  VitalsModel copyWith({
    double? heartRate,
    double? spo2,
    double? temperature,
    double? respiratoryRate,
    RiskLevel? riskLevel,
    double? riskProbability,
    bool? isConnected,
    bool? riskApiOnline,
    bool? riskPredictLoading,
    DateTime? lastUpdated,
  }) {
    return VitalsModel(
      heartRate:       heartRate       ?? this.heartRate,
      spo2:            spo2            ?? this.spo2,
      temperature:     temperature     ?? this.temperature,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      riskLevel:       riskLevel       ?? this.riskLevel,
      riskProbability: riskProbability ?? this.riskProbability,
      isConnected:     isConnected     ?? this.isConnected,
      riskApiOnline:   riskApiOnline   ?? this.riskApiOnline,
      riskPredictLoading: riskPredictLoading ?? this.riskPredictLoading,
      lastUpdated:     lastUpdated     ?? this.lastUpdated,
    );
  }

  // ─── JSON ──────────────────────────────────────────────────────────────────
  factory VitalsModel.fromJson(Map<String, dynamic> json) {
    RiskLevel risk;
    switch ((json['risk_level'] as String).toLowerCase()) {
      case 'critical': risk = RiskLevel.critical; break;
      case 'warning':  risk = RiskLevel.warning;  break;
      default:         risk = RiskLevel.low;
    }
    return VitalsModel(
      heartRate:       (json['heart_rate']       as num).toDouble(),
      spo2:            (json['spo2']             as num).toDouble(),
      temperature:     (json['temperature']      as num).toDouble(),
      respiratoryRate: (json['respiratory_rate'] as num).toDouble(),
      riskLevel:       risk,
      riskProbability: (json['risk_probability'] as num).toDouble(),
      isConnected:     json['connected'] as bool? ?? true,
      lastUpdated:     DateTime.now(),
    );
  }

  // ─── Defaults ──────────────────────────────────────────────────────────────
  static VitalsModel get initial => VitalsModel(
    heartRate:       78,
    spo2:            98,
    temperature:     36.7,
    respiratoryRate: 18,
    riskLevel:       RiskLevel.low,
    riskProbability: 0.07,
    isConnected:     true,
    riskApiOnline:   false,
    riskPredictLoading: false,
    lastUpdated:     DateTime.now(),
  );
}
