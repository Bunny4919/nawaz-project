import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_bar.dart';
import 'dashboard_screen.dart';

class MockTestResultScreen extends StatelessWidget {
  final MockTest mockTest;
  final List<Question> questions;
  final List<AnsweredQuestion> answeredState;
  final bool wasAutoSubmitted;

  const MockTestResultScreen({
    super.key,
    required this.mockTest,
    required this.questions,
    required this.answeredState,
    required this.wasAutoSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();

    int correctCount = 0;
    int wrongCount = 0;
    int skippedCount = 0;

    // Per subject breakdown
    final Map<String, StatCounter> localSubjectStats = {};

    for (var aq in answeredState) {
      final subId = aq.question.subjectId;
      localSubjectStats.putIfAbsent(subId, () => StatCounter());

      if (!aq.isAnswered) {
        skippedCount++;
      } else if (aq.isCorrect) {
        correctCount++;
        localSubjectStats[subId]!.attempted++;
        localSubjectStats[subId]!.correct++;
      } else {
        wrongCount++;
        localSubjectStats[subId]!.attempted++;
      }
    }

    final total = answeredState.length;
    final accuracy = total == 0 ? 0.0 : (correctCount / total) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Mock Test Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wasAutoSubmitted) ...[
              Card(
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.timer_off_outlined, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Time Out! Test was automatically submitted.',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Score Banner Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      mockTest.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Score: $correctCount / $total',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatBox(label: 'Correct', count: correctCount, color: Colors.green),
                        _StatBox(label: 'Wrong', count: wrongCount, color: Colors.red),
                        _StatBox(label: 'Skipped', count: skippedCount, color: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Per Subject Breakdown
            Text(
              'Per-Subject Performance',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: provider.subjects.map((sub) {
                    final stat = localSubjectStats[sub.id];
                    if (stat == null || mockTest.subjectQuestionCounts[sub.id] == null) {
                      return const SizedBox.shrink();
                    }

                    final subjectAcc = stat.attempted == 0
                        ? 0.0
                        : (stat.correct / mockTest.subjectQuestionCounts[sub.id]!) * 100;

                    return StatBar(
                      label: sub.name,
                      percentage: subjectAcc,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text(
                  'Back to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatBox({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
