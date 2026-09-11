import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'quiz_screen.dart';

class MistakeBookScreen extends StatefulWidget {
  const MistakeBookScreen({super.key});

  @override
  State<MistakeBookScreen> createState() => _MistakeBookScreenState();
}

class _MistakeBookScreenState extends State<MistakeBookScreen> {
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final mistakes = provider.mistakeBook;

    final filteredMistakes = mistakes.where((m) {
      if (_selectedSubjectId != null && m.question.subjectId != _selectedSubjectId) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('❌ Mistake Book'),
      ),
      body: mistakes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 80,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Mistakes Yet!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great job! Incorrect answers from your practice quizzes will automatically appear here.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Subject Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Subjects'),
                        selected: _selectedSubjectId == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSubjectId = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...provider.subjects.map((sub) {
                        final isSelected = _selectedSubjectId == sub.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(sub.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSubjectId = selected ? sub.id : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMistakes.length,
                    itemBuilder: (context, index) {
                      final entry = filteredMistakes[index];
                      final q = entry.question;

                      final userAns = entry.selectedIndex >= 0 &&
                              entry.selectedIndex < q.options.length
                          ? q.options[entry.selectedIndex]
                          : 'No answer';
                      final correctAns = q.options[q.correctIndex];

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
                                  Chip(
                                    avatar: const Icon(Icons.label_outline, size: 14),
                                    label: Text(
                                      '${q.subjectId.replaceAll('sub_', '').toUpperCase()} • ${q.topicId.replaceAll('top_', '').replaceAll('_', ' ').toUpperCase()}',
                                      style: const TextStyle(
                                          fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                q.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Answer: $userAns',
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Correct Answer: $correctAns',
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '💡 Explanation: ${q.explanation}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => QuizScreen(questions: [q]),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Practice Again'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Practice All Mistakes Button at bottom
                if (filteredMistakes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final allMistakeQuestions =
                              filteredMistakes.map((m) => m.question).toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(questions: allMistakeQuestions),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_fill),
                        label: Text(
                          'Practice All Mistakes (${filteredMistakes.length})',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
