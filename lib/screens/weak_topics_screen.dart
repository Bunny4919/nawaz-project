import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_bar.dart';
import 'notes_screen.dart';
import 'quiz_setup_screen.dart';

class WeakTopicsScreen extends StatelessWidget {
  const WeakTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final weakTopicsList = provider.weakTopics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚠️ Weak Topics Focus'),
      ),
      body: weakTopicsList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 80,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Weak Topics Identified!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Either all your attempted topics are above 60% accuracy, or you haven\'t attempted any questions yet.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: weakTopicsList.length,
              itemBuilder: (context, index) {
                final topic = weakTopicsList[index];
                final subject = provider.subjects.firstWhere(
                  (s) => s.id == topic.subjectId,
                  orElse: () => provider.subjects.first,
                );
                final stat = provider.topicStats[topic.id];
                final accuracy = stat?.accuracy ?? 0.0;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.deepOrange.shade800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    subject.name,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StatBar(
                          label: 'Current Accuracy',
                          percentage: accuracy,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NotesScreen(
                                        initialSubjectId: subject.id,
                                        initialTopicId: topic.id,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.menu_book, size: 18),
                                label: const Text('Read Notes'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuizSetupScreen(
                                        initialMode: QuizMode.topicWise,
                                        initialSubjectId: subject.id,
                                        initialTopicId: topic.id,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Retest Topic'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
