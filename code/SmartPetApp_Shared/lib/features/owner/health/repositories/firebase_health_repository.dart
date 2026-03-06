import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'health_repository.dart';
import '../models/health_vitals.dart';

class FirebaseHealthRepository implements HealthRepository {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('Firebase health repository initialized');
  }

  @override
  Stream<HealthVitals> getHealthVitalsStream(String petId) {
    return _database.ref('pets/$petId/health').onValue.map((event) {
      if (event.snapshot.value == null) {
        // Return default/empty vitals if nothing exists yet
        return HealthVitals(heartRate: 0, temperature: 0.0, timestamp: DateTime.now());
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return HealthVitals.fromJson(data);
    });
  }

  @override
Future<List<HealthVitals>> getHealthHistoryForDay(String petId, DateTime day) async {
  final startOfDay = DateTime(day.year, day.month, day.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  final snapshot = await _database
      .ref('pets/$petId/health_history')
      .orderByKey()
      .startAt(startOfDay.toIso8601String().substring(0, 10)) // "2026-03-03"
      .endAt(endOfDay.toIso8601String().substring(0, 10) + '\uf8ff')
      .get();

  if (snapshot.value == null) return [];

  final Map<dynamic, dynamic> raw = snapshot.value as Map;
  return raw.values
      .map((e) => HealthVitals.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
}
}