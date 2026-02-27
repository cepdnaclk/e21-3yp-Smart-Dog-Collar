import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/health_service.dart';
import '../models/health_vitals.dart';

// Provider for HealthService instance
final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

// Provider for continuous health vitals tracking stream
final healthVitalsStreamProvider = StreamProvider<HealthVitals>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  return healthService.getHealthVitalsStream();
});