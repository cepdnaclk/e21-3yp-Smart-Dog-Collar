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
}