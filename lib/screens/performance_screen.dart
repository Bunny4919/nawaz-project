import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_bar.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    final hasAttempted = provider.totalAttempted > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Performance & Analytics'),
      ),
      body: !hasAttempted
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Attempts Recorded Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take a practice quiz or mock test to view detailed performance metrics, strength analyses, and accuracy breakdowns.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Stats Grid
                  Text(
                    'Overall Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _PerfTile(
                        title: 'Overall Accuracy',
                        value: '${provider.overallAccuracy.toStringAsFixed(1)}%',
                        icon: Icons.track_changes,
                        color: Colors.purple,
                      ),
                      _PerfTile(
                        title: 'Questions Attempted',
                        value: '${provider.totalAttempted}',
                        icon: Icons.quiz,
                        color: Colors.blue,
                      ),
                      _PerfTile(
                        title: 'Quizzes Completed',
                        value: '${provider.quizzesCompleted}',
                        icon: Icons.check_circle_outline,
                        color: Colors.teal,
                      ),
                      _PerfTile(
                        title: 'Mock Tests Completed',
                        value: '${provider.mockTestsCompleted}',
                        icon: Icons.assignment_turned_in,
                        color: Colors.indigo,
                      ),
                      _PerfTile(
                        title: 'Total Correct',
                        value: '${provider.totalCorrect}',
                        icon: Icons.thumb_up_alt_outlined,
                        color: Colors.green,
                      ),
                      _PerfTile(
                        title: 'Total Wrong',
                        value: '${provider.totalWrong}',
                        icon: Icons.thumb_down_alt_outlined,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Strongest & Weakest Callouts
                  Text(
                    'Subject Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.green.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.green.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.green.shade700, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Strongest',
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  provider.strongestSubject?.name ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          color: Colors.red.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Weakest',
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  provider.weakestSubject?.name ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Subject-wise Accuracy
                  Text(
                    'Subject-wise Accuracy',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: provider.subjects.map((sub) {
                          final stat = provider.subjectStats[sub.id];
                          final acc = stat?.accuracy ?? 0.0;
                          return StatBar(
                            label: sub.name,
                            percentage: acc,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Topic-wise Accuracy
                  Text(
                    'Topic-wise Accuracy',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: provider.subjects.expand((sub) {
                          return sub.topics.map((t) {
                            final stat = provider.topicStats[t.id];
                            final acc = stat?.accuracy ?? 0.0;
                            return StatBar(
                              label: '${sub.name} - ${t.name}',
                              percentage: acc,
                            );
                          });
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PerfTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _PerfTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
