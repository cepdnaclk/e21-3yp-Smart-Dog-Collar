// lib/features/owner/activity/providers/activity_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_data.dart';
import '../repositories/firebase_activity_repository.dart';

final _activityRepo = FirebaseActivityRepository();

/// Live current activity (e.g. "walking", accelerometer values)
final currentActivityProvider = StreamProvider<ActivityData?>((ref) {
  return _activityRepo.getCurrentActivityStream();
});

/// Last 50 activity history entries
final activityHistoryProvider = StreamProvider<List<ActivityData>>((ref) {
  return _activityRepo.getActivityHistoryStream(limit: 50);
});

/// Daily summaries for the last 7 days (used for bar chart)
final dailySummariesProvider = StreamProvider<List<ActivitySummary>>((ref) {
  return _activityRepo.getDailySummariesStream(days: 7);
});

/// Impact events only
final impactAlertsProvider = StreamProvider<List<ActivityData>>((ref) {
  return _activityRepo.getImpactAlertsStream(limit: 20);
});
