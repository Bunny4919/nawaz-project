import 'package:flutter/material.dart';
import '../models/models.dart';
import 'dashboard_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final List<Question> questions;
  final Map<int, int> userAnswers; // index -> selectedIndex

  const QuizResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = questions.length;

    int correctCount = 0;
    int wrongCount = 0;
    int skippedCount = 0;

    for (int i = 0; i < total; i++) {
      final selected = userAnswers[i];
      if (selected == null || selected < 0) {
        skippedCount++;
      } else if (selected == questions[i].correctIndex) {
        correctCount++;
      } else {
        wrongCount++;
      }
    }

    final accuracy = total == 0 ? 0.0 : (correctCount / total) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Card
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
                      'Quiz Completed!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score: $correctCount / $total',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ResultMetricTile(
                          label: 'Correct',
                          count: correctCount,
                          color: Colors.green,
                        ),
                        _ResultMetricTile(
                          label: 'Wrong',
                          count: wrongCount,
                          color: Colors.red,
                        ),
                        _ResultMetricTile(
                          label: 'Skipped',
                          count: skippedCount,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Review Answers',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Expandable Review Answers List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: total,
              itemBuilder: (context, index) {
                final q = questions[index];
                final selected = userAnswers[index];
                final isCorrect = selected == q.correctIndex;
                final isSkipped = selected == null || selected < 0;

                final String userAnsText = isSkipped
                    ? 'Skipped'
                    : q.options[selected];
                final String correctAnsText = q.options[q.correctIndex];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isCorrect
                          ? Colors.green.shade100
                          : isSkipped
                              ? Colors.orange.shade100
                              : Colors.red.shade100,
                      child: Icon(
                        isCorrect
                            ? Icons.check
                            : isSkipped
                                ? Icons.remove
                                : Icons.close,
                        color: isCorrect
                            ? Colors.green.shade800
                            : isSkipped
                                ? Colors.orange.shade800
                                : Colors.red.shade800,
                      ),
                    ),
                    title: Text(
                      'Q${index + 1}: ${q.text}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      isCorrect
                          ? 'Correct'
                          : isSkipped
                              ? 'Skipped'
                              : 'Incorrect',
                      style: TextStyle(
                        color: isCorrect
                            ? Colors.green
                            : isSkipped
                                ? Colors.orange
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            Text(
                              'Your Answer: $userAnsText',
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isCorrect)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Correct Answer: $correctAnsText',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '💡 Explanation: ${q.explanation}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Back to Dashboard Button
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

class _ResultMetricTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _ResultMetricTile({
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
