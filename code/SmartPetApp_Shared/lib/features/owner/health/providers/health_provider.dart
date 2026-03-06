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

final _historyRefreshTickerProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (i) => i);
});

final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final healthHistoryProvider = FutureProvider.autoDispose<List<HealthVitals>>((ref) async {
  final service = ref.watch(healthServiceProvider);
  final day = ref.watch(selectedDayProvider);

  // Watch the ticker only if today is selected — forces re-fetch every 30s
  final now = DateTime.now();
  final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
  if (isToday) {
    ref.watch(_historyRefreshTickerProvider);
  }

  return service.getHealthHistoryForDay(day);
});