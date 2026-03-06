// lib/features/owner/activity/providers/activity_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_data.dart';
import '../repositories/firebase_activity_repository.dart';

// ✅ Repo created inside provider — guaranteed Firebase is ready
final _activityRepoProvider = Provider<FirebaseActivityRepository>((ref) {
  return FirebaseActivityRepository();
});

final currentActivityProvider = StreamProvider<ActivityData?>((ref) {
  return ref.watch(_activityRepoProvider).getCurrentActivityStream();
});

final activityHistoryProvider = StreamProvider<List<ActivityData>>((ref) {
  return ref.watch(_activityRepoProvider).getActivityHistoryStream(limit: 50);
});

final dailySummariesProvider = StreamProvider<List<ActivitySummary>>((ref) {
  return ref.watch(_activityRepoProvider).getDailySummariesStream(days: 7);
});

final impactAlertsProvider = StreamProvider<List<ActivityData>>((ref) {
  return ref.watch(_activityRepoProvider).getImpactAlertsStream(limit: 20);
});