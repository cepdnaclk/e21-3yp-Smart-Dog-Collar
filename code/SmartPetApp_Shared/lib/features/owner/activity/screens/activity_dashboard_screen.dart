// lib/features/owner/activity/screens/activity_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/activity_provider.dart';
import '../models/activity_data.dart';

class ActivityDashboardScreen extends ConsumerStatefulWidget {
  const ActivityDashboardScreen({super.key});

  @override
  ConsumerState<ActivityDashboardScreen> createState() =>
      _ActivityDashboardScreenState();
}

class _ActivityDashboardScreenState
    extends ConsumerState<ActivityDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color _primary = Color.fromARGB(255, 0, 150, 136);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Monitor'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.monitor), text: 'Live'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Summary'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LiveTab(),
          _SummaryTab(),
          _HistoryTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: LIVE
// ─────────────────────────────────────────────────────────────────────────────

class _LiveTab extends ConsumerWidget {
  const _LiveTab();

  static const Color _primary = Color.fromARGB(255, 0, 150, 136);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(currentActivityProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(currentActivityProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: activityAsync.when(
          data: (activity) {
            if (activity == null) {
              return const _NoDataCard(
                message: 'No live activity data yet.\nData will appear once the sensor is connected.',
              );
            }
            return Column(
              children: [
                _ActivityStatusCard(activity: activity),
                const SizedBox(height: 16),
                if (activity.impactDetected)
                  _ImpactAlertBanner(severity: activity.impactSeverity),
                if (activity.impactDetected) const SizedBox(height: 16),
                _PetWellnessCard(activity: activity),
                const SizedBox(height: 16),
                _StepsCard(activity: activity),
              ],
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: _primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Connecting to sensor...',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => ref.invalidate(currentActivityProvider),
                    child: const Text('Tap to retry',
                        style: TextStyle(color: _primary)),
                  ),
                ],
              ),
            ),
          ),
          error: (e, _) => _ErrorCard(error: e),
        ),
      ),
    );
  }
} // ← _LiveTab closes here

// ─────────────────────────────────────────────────────────────────────────────
// FRIENDLY PET WELLNESS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PetWellnessCard extends StatelessWidget {
  final ActivityData activity;
  const _PetWellnessCard({required this.activity});

  static const Color _primary = Color.fromARGB(255, 0, 150, 136);

  String _movementIntensity(double magnitude) {
    if (magnitude > 20) return 'Very High';
    if (magnitude > 13) return 'High';
    if (magnitude > 11) return 'Moderate';
    if (magnitude > 10) return 'Low';
    return 'Very Low';
  }

  Color _movementColor(double magnitude) {
    if (magnitude > 20) return Colors.red;
    if (magnitude > 13) return Colors.orange;
    if (magnitude > 11) return Colors.blue;
    if (magnitude > 10) return Colors.green;
    return Colors.purple;
  }

  String _bodyStability(double gx, double gy, double gz) {
    final gyroMag = (gx * gx + gy * gy + gz * gz);
    if (gyroMag > 2.0) return 'Spinning / Shaking';
    if (gyroMag > 0.5) return 'Moving around';
    if (gyroMag > 0.05) return 'Slightly shifting';
    return 'Calm & Steady';
  }

  IconData _stabilityIcon(double gx, double gy, double gz) {
    final gyroMag = (gx * gx + gy * gy + gz * gz);
    if (gyroMag > 2.0) return Icons.rotate_right;
    if (gyroMag > 0.5) return Icons.waves;
    if (gyroMag > 0.05) return Icons.swap_calls;
    return Icons.spa;
  }

  String _posture(double ay) {
    if (ay > 9.0) return 'Upright / Standing';
    if (ay > 5.0) return 'Leaning / Tilted';
    return 'Lying Down';
  }

  IconData _postureIcon(double ay) {
    if (ay > 9.0) return Icons.vertical_align_top;
    if (ay > 5.0) return Icons.trending_down;
    return Icons.horizontal_rule;
  }

  String _wellnessMessage(ActivityData a) {
    if (a.impactDetected) return 'Check on your pet — a fall or bump was detected!';
    switch (a.activityType) {
      case 'running': return 'Your pet is getting great exercise! 🏃';
      case 'walking': return 'Your pet is enjoying a nice walk! 🐾';
      case 'playing': return 'Your pet is happy and playful! 🎾';
      case 'resting': return 'Your pet is relaxing comfortably. 😴';
      default: return 'Your pet is doing well! 🐶';
    }
  }

  @override
  Widget build(BuildContext context) {
    final intensity = _movementIntensity(activity.magnitude);
    final intensityColor = _movementColor(activity.magnitude);
    final stability = _bodyStability(
        activity.gyroscopeX, activity.gyroscopeY, activity.gyroscopeZ);
    final stabilityIcon = _stabilityIcon(
        activity.gyroscopeX, activity.gyroscopeY, activity.gyroscopeZ);
    final posture = _posture(activity.accelerometerY);
    final postureIcon = _postureIcon(activity.accelerometerY);
    final intensityFraction = (activity.magnitude / 25.0).clamp(0.0, 1.0);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite, color: Color.fromARGB(255, 0, 150, 136)),
                SizedBox(width: 8),
                Text('Pet Wellness',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _wellnessMessage(activity),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _WellnessTile(
                    icon: Icons.bolt,
                    iconColor: intensityColor,
                    bgColor: intensityColor.withOpacity(0.1),
                    title: 'Movement',
                    value: intensity,
                    subtitle: 'Intensity level',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WellnessTile(
                    icon: stabilityIcon,
                    iconColor: Colors.indigo,
                    bgColor: Colors.indigo.withOpacity(0.1),
                    title: 'Balance',
                    value: stability,
                    subtitle: 'Body stability',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _WellnessTile(
                    icon: postureIcon,
                    iconColor: Colors.teal,
                    bgColor: Colors.teal.withOpacity(0.1),
                    title: 'Posture',
                    value: posture,
                    subtitle: 'Body position',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WellnessTile(
                    icon: activity.impactDetected
                        ? Icons.warning_amber
                        : Icons.shield,
                    iconColor:
                        activity.impactDetected ? Colors.red : Colors.green,
                    bgColor: activity.impactDetected
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    title: 'Safety',
                    value: activity.impactDetected ? 'Check Pet!' : 'All Good',
                    subtitle: 'No issues detected',
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text('Movement Intensity',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: 12,
                  width: MediaQuery.of(context).size.width *
                      intensityFraction *
                      0.75,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.orange, Colors.red],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calm', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Active', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Very Active', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WellnessTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String value;
  final String subtitle;

  const _WellnessTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 11,
                      color: iconColor,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: SUMMARY
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryTab extends ConsumerWidget {
  const _SummaryTab();

  static const Color _primary = Color.fromARGB(255, 0, 150, 136);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(dailySummariesProvider);
    final impactAsync = ref.watch(impactAlertsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dailySummariesProvider);
        ref.invalidate(impactAlertsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('7-Day Activity Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            summariesAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return const _NoDataCard(
                      message: 'No summary data yet.\nManually add data to Firebase to see charts.');
                }
                return Column(
                  children: [
                    _StepsBarChart(summaries: summaries),
                    const SizedBox(height: 16),
                    _ActiveMinutesChart(summaries: summaries),
                    const SizedBox(height: 16),
                    _SummaryStatsRow(summaries: summaries),
                  ],
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: _primary)),
              error: (e, _) => _ErrorCard(error: e),
            ),
            const SizedBox(height: 24),
            const Text('Recent Impacts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            impactAsync.when(
              data: (impacts) {
                if (impacts.isEmpty) {
                  return const _NoDataCard(
                      message: 'No impacts recorded. Your pet is safe! 🐾');
                }
                return Column(
                  children: impacts
                      .take(5)
                      .map((i) => _ImpactListTile(activity: i))
                      .toList(),
                );
              },
              loading: () => const Center(
                  child: CircularProgressIndicator(color: _primary)),
              error: (e, _) => _ErrorCard(error: e),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: HISTORY
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  static const Color _primary = Color.fromARGB(255, 0, 150, 136);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(activityHistoryProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(activityHistoryProvider),
      child: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const _NoDataCard(
                message: 'No history yet.\nAdd data to Firebase to see logs here.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) => _HistoryTile(activity: history[i]),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (e, _) => Center(child: _ErrorCard(error: e)),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _ActivityStatusCard extends StatelessWidget {
  final ActivityData activity;
  const _ActivityStatusCard({required this.activity});

  static const _activityColors = {
    'walking': Color(0xFF4CAF50),
    'running': Color(0xFF2196F3),
    'resting': Color(0xFF9C27B0),
    'playing': Color(0xFFFF9800),
    'impact': Color(0xFFF44336),
  };

  static const _activityEmojis = {
    'walking': '🐕',
    'running': '🐕‍🦺',
    'resting': '🐾',
    'playing': '🦴',
    'impact': '⚠️',
  };

  @override
  Widget build(BuildContext context) {
    final color = _activityColors[activity.activityType] ?? Colors.teal;
    final emoji = _activityEmojis[activity.activityType] ?? '🐶';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Activity',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  activity.activityType.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(activity.timestamp),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _StatBubble(value: '${activity.stepCount}', label: 'Steps'),
              const SizedBox(height: 8),
              _StatBubble(
                  value: '${activity.activeMinutes.toStringAsFixed(0)}m',
                  label: 'Active'),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.day}/${dt.month}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _StatBubble extends StatelessWidget {
  final String value;
  final String label;
  const _StatBubble({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ImpactAlertBanner extends StatelessWidget {
  final double severity;
  const _ImpactAlertBanner({required this.severity});

  @override
  Widget build(BuildContext context) {
    final isHigh = severity >= 7.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHigh ? Colors.red.shade50 : Colors.orange.shade50,
        border:
            Border.all(color: isHigh ? Colors.red : Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber,
              color: isHigh ? Colors.red : Colors.orange, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHigh ? '🚨 HIGH IMPACT DETECTED!' : '⚠️ Impact Detected',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isHigh ? Colors.red : Colors.orange,
                      fontSize: 15),
                ),
                Text(
                  'Severity: ${severity.toStringAsFixed(1)} / 10',
                  style: const TextStyle(color: Colors.black87),
                ),
                if (isHigh)
                  const Text(
                    'Consider checking on your pet!',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  final ActivityData activity;
  const _StepsCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final progress = (activity.activeMinutes / 60.0).clamp(0.0, 1.0);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Text('🐾', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Activity Progress',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BigStat(
                    value: '${activity.stepCount}', label: 'Steps Today'),
                _BigStat(
                    value: '${activity.activeMinutes.toStringAsFixed(0)} min',
                    label: 'Active Time'),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Daily Goal Progress (60 min)',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: const Color.fromARGB(255, 0, 150, 136),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 4),
            Text('${(progress * 100).toStringAsFixed(0)}% of daily goal',
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  const _BigStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 150, 136))),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// ─── Bar Charts ───────────────────────────────────────────────────────────────

class _StepsBarChart extends StatelessWidget {
  final List<ActivitySummary> summaries;
  const _StepsBarChart({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final maxSteps =
        summaries.map((s) => s.totalSteps).reduce((a, b) => a > b ? a : b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Steps per Day',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: summaries.reversed.take(7).map((s) {
                  final heightFraction =
                      maxSteps > 0 ? s.totalSteps / maxSteps : 0.0;
                  return _Bar(
                    heightFraction: heightFraction,
                    label: _dayLabel(s.date),
                    value: '${s.totalSteps}',
                    color: const Color.fromARGB(255, 0, 150, 136),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
}

class _ActiveMinutesChart extends StatelessWidget {
  final List<ActivitySummary> summaries;
  const _ActiveMinutesChart({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final maxMins = summaries
        .map((s) => s.totalActiveMinutes)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Minutes per Day',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: summaries.reversed.take(7).map((s) {
                  final heightFraction =
                      maxMins > 0 ? s.totalActiveMinutes / maxMins : 0.0;
                  return _Bar(
                    heightFraction: heightFraction,
                    label: _dayLabel(s.date),
                    value: '${s.totalActiveMinutes.toStringAsFixed(0)}m',
                    color: Colors.blue,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
}

class _Bar extends StatelessWidget {
  final double heightFraction;
  final String label;
  final String value;
  final Color color;
  const _Bar({
    required this.heightFraction,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 9, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 28,
          height: (heightFraction * 100).clamp(4.0, 100.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _SummaryStatsRow extends StatelessWidget {
  final List<ActivitySummary> summaries;
  const _SummaryStatsRow({required this.summaries});

  @override
  Widget build(BuildContext context) {
    final totalSteps = summaries.fold(0, (sum, s) => sum + s.totalSteps);
    final totalMins =
        summaries.fold(0.0, (sum, s) => sum + s.totalActiveMinutes);
    final totalImpacts = summaries.fold(0, (sum, s) => sum + s.impactCount);

    return Row(
      children: [
        Expanded(
            child: _SummaryChip(
                icon: Icons.pets,
                value: '$totalSteps',
                label: 'Total Steps',
                color: Colors.teal)),
        const SizedBox(width: 8),
        Expanded(
            child: _SummaryChip(
                icon: Icons.timer,
                value: '${totalMins.toStringAsFixed(0)}m',
                label: 'Active Time',
                color: Colors.blue)),
        const SizedBox(width: 8),
        Expanded(
            child: _SummaryChip(
                icon: Icons.warning_amber,
                value: '$totalImpacts',
                label: 'Impacts',
                color: totalImpacts > 0 ? Colors.red : Colors.green)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _SummaryChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ImpactListTile extends StatelessWidget {
  final ActivityData activity;
  const _ImpactListTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final isHigh = activity.impactSeverity >= 7.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isHigh ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isHigh ? Colors.red.shade200 : Colors.orange.shade200),
      ),
      child: ListTile(
        leading: Icon(Icons.warning_amber,
            color: isHigh ? Colors.red : Colors.orange),
        title: Text(
            'Severity: ${activity.impactSeverity.toStringAsFixed(1)}/10',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${activity.timestamp.day}/${activity.timestamp.month} at '
            '${activity.timestamp.hour.toString().padLeft(2, '0')}:'
            '${activity.timestamp.minute.toString().padLeft(2, '0')}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHigh ? Colors.red : Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isHigh ? 'HIGH' : 'MED',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ActivityData activity;
  const _HistoryTile({required this.activity});

  static const _activityColors = {
    'walking': Color(0xFF4CAF50),
    'running': Color(0xFF2196F3),
    'resting': Color(0xFF9C27B0),
    'playing': Color(0xFFFF9800),
    'impact': Color(0xFFF44336),
  };

  static const _activityEmojis = {
    'walking': '🐕',
    'running': '🐕‍🦺',
    'resting': '🐾',
    'playing': '🦴',
    'impact': '⚠️',
  };

  @override
  Widget build(BuildContext context) {
    final color = _activityColors[activity.activityType] ?? Colors.teal;
    final emoji = _activityEmojis[activity.activityType] ?? '🐶';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.activityType.toUpperCase(),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    '${activity.timestamp.day}/${activity.timestamp.month}  '
                    '${activity.timestamp.hour.toString().padLeft(2, '0')}:'
                    '${activity.timestamp.minute.toString().padLeft(2, '0')}',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${activity.stepCount} steps',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                if (activity.impactDetected)
                  const Text('⚠️ Impact',
                      style: TextStyle(color: Colors.red, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helper widgets ────────────────────────────────────────────────────

class _NoDataCard extends StatelessWidget {
  final String message;
  const _NoDataCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.sensors_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final Object error;
  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12)),
      child:
          Text('Error: $error', style: const TextStyle(color: Colors.red)),
    );
  }
}