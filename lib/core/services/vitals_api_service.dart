import 'package:dio/dio.dart';
import '../models/vitals_model.dart';

class RiskPrediction {
  final RiskLevel riskLevel;
  final double riskProbability;
  RiskPrediction(this.riskLevel, this.riskProbability);
}

/// Stub API service — swap baseUrl + endpoints to connect the real ESP32 backend.
class VitalsApiService {
  static const String _baseUrl = 'http://192.168.1.100:8080';
  static const String _mlApiUrl = 'https://abood121212-vital-risk-api-new.hf.space';

  late final Dio _dio;
  late final Dio _mlDio;

  VitalsApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _mlDio = Dio(
      BaseOptions(
        baseUrl: _mlApiUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
  }

  /// Fetch current vitals from the ESP32 backend.
  /// Returns null on failure (caller falls back to last known state).
  Future<VitalsModel?> fetchVitals() async {
    try {
      final response = await _dio.get('/vitals');
      if (response.statusCode == 200) {
        return VitalsModel.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException {
      // Network error — caller will handle gracefully
    }
    return null;
  }

  Future<RiskPrediction> predictRisk({
    required double heartRate,
    required double oxygenSaturation,
    required double temperature,
    required double respiratoryRate,
  }) async {
    try {
      final response = await _mlDio.get('/predict', queryParameters: {
        'heart_rate': heartRate,
        'oxygen_saturation': oxygenSaturation,
        'temperature': temperature,
        'respiratory_rate': respiratoryRate,
      });
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        RiskLevel level;
        switch (data['risk_label']) {
          case 'CRITICAL_RISK':
            level = RiskLevel.critical;
            break;
          case 'WARNING':
            level = RiskLevel.warning;
            break;
          case 'LOW_RISK':
          default:
            level = RiskLevel.low;
            break;
        }
        return RiskPrediction(level, (data['risk_probability'] as num).toDouble());
      }
    } catch (e) {
      // Handle gracefully by throwing to caller which falls back
    }
    throw Exception('Failed to fetch risk');
  }
}
