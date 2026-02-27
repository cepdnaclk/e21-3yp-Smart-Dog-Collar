class HealthVitals {
  final int heartRate;
  final double temperature;
  final DateTime timestamp;

  HealthVitals({
    required this.heartRate,
    required this.temperature,
    required this.timestamp,
  });

  factory HealthVitals.fromJson(Map<String, dynamic> json) {
    return HealthVitals(
      heartRate: (json['heartRate'] as num?)?.toInt() ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heartRate': heartRate,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum VitalStatus { normal, caution, danger }

extension HealthVitalsStatus on HealthVitals {
  VitalStatus get heartRateStatus {
    if (heartRate >= 60 && heartRate <= 140) return VitalStatus.normal;
    if (heartRate >= 40 && heartRate <= 160) return VitalStatus.caution;
    return VitalStatus.danger;
  }

  VitalStatus get temperatureStatus {
    if (temperature >= 38.0 && temperature <= 39.2) return VitalStatus.normal;
    if (temperature >= 37.2 && temperature <= 40.0) return VitalStatus.caution;
    return VitalStatus.danger;
  }
}