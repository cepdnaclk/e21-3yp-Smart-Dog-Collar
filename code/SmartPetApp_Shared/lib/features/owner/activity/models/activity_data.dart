// lib/features/owner/activity/models/activity_data.dart

class ActivityData {
  final String activityType; // "walking", "running", "resting", "playing", "impact"
  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;
  final double gyroscopeX;
  final double gyroscopeY;
  final double gyroscopeZ;
  final double magnitude; // sqrt(ax^2 + ay^2 + az^2)
  final bool impactDetected;
  final double impactSeverity; // 0.0 - 10.0
  final DateTime timestamp;
  final int stepCount;
  final double activeMinutes;

  ActivityData({
    required this.activityType,
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    required this.gyroscopeX,
    required this.gyroscopeY,
    required this.gyroscopeZ,
    required this.magnitude,
    required this.impactDetected,
    required this.impactSeverity,
    required this.timestamp,
    required this.stepCount,
    required this.activeMinutes,
  });

  // Create from Firebase Realtime Database snapshot map
  factory ActivityData.fromMap(Map<dynamic, dynamic> map) {
    return ActivityData(
      activityType: map['activity_type'] ?? 'resting',
      accelerometerX: (map['accelerometer']?['x'] ?? 0.0).toDouble(),
      accelerometerY: (map['accelerometer']?['y'] ?? 0.0).toDouble(),
      accelerometerZ: (map['accelerometer']?['z'] ?? 0.0).toDouble(),
      gyroscopeX: (map['gyroscope']?['x'] ?? 0.0).toDouble(),
      gyroscopeY: (map['gyroscope']?['y'] ?? 0.0).toDouble(),
      gyroscopeZ: (map['gyroscope']?['z'] ?? 0.0).toDouble(),
      magnitude: (map['magnitude'] ?? 0.0).toDouble(),
      impactDetected: map['impact_detected'] ?? false,
      impactSeverity: (map['impact_severity'] ?? 0.0).toDouble(),
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      stepCount: (map['step_count'] ?? 0).toInt(),
      activeMinutes: (map['active_minutes'] ?? 0.0).toDouble(),
    );
  }

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'activity_type': activityType,
      'accelerometer': {
        'x': accelerometerX,
        'y': accelerometerY,
        'z': accelerometerZ,
      },
      'gyroscope': {
        'x': gyroscopeX,
        'y': gyroscopeY,
        'z': gyroscopeZ,
      },
      'magnitude': magnitude,
      'impact_detected': impactDetected,
      'impact_severity': impactSeverity,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'step_count': stepCount,
      'active_minutes': activeMinutes,
    };
  }
}

// Summary model for daily activity stats
class ActivitySummary {
  final int totalSteps;
  final double totalActiveMinutes;
  final int impactCount;
  final Map<String, double> activityBreakdown; // e.g. {"walking": 60.0, "resting": 300.0}
  final DateTime date;

  ActivitySummary({
    required this.totalSteps,
    required this.totalActiveMinutes,
    required this.impactCount,
    required this.activityBreakdown,
    required this.date,
  });

  factory ActivitySummary.fromMap(Map<dynamic, dynamic> map) {
    Map<String, double> breakdown = {};
    if (map['activity_breakdown'] != null) {
      (map['activity_breakdown'] as Map).forEach((k, v) {
        breakdown[k.toString()] = (v ?? 0.0).toDouble();
      });
    }
    return ActivitySummary(
      totalSteps: (map['total_steps'] ?? 0).toInt(),
      totalActiveMinutes: (map['total_active_minutes'] ?? 0.0).toDouble(),
      impactCount: (map['impact_count'] ?? 0).toInt(),
      activityBreakdown: breakdown,
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now(),
    );
  }
}
