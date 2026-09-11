import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  final Map<int, int> _userAnswers = {}; // questionIndex -> selectedIndex

  void _selectOption(int optionIndex) {
    setState(() {
      _userAnswers[_currentIndex] = optionIndex;
    });
  }

  void _handleNextOrSubmit() {
    final currentQ = widget.questions[_currentIndex];
    final selectedIdx = _userAnswers[_currentIndex] ?? -1;

    if (selectedIdx != -1) {
      context.read<AppProvider>().recordAnswer(currentQ, selectedIdx);
    }

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // Last question completed
      context.read<AppProvider>().completeQuiz(isMockTest: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            questions: widget.questions,
            userAnswers: _userAnswers,
          ),
        ),
      );
    }
  }

  Color _getDifficultyColor(Difficulty diff) {
    switch (diff) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final question = widget.questions[_currentIndex];
    final selectedOption = _userAnswers[_currentIndex];

    final totalQuestions = widget.questions.length;
    final progress = (_currentIndex + 1) / totalQuestions;

    // Check if live question is bookmarked in provider
    final isBookmarked = provider.questions
        .firstWhere((q) => q.id == question.id, orElse: () => question)
        .bookmarked;

    const optionLetters = ['A', 'B', 'C', 'D'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1} of $totalQuestions'),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.amber : null,
            ),
            onPressed: () {
              provider.toggleQuestionBookmark(question.id);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Linear Progress Indicator
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic & Difficulty Badge Row
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(
                          Icons.local_offer_outlined,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          question.topicId.replaceAll('top_', '').replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        backgroundColor: _getDifficultyColor(question.difficulty).withValues(alpha: 0.15),
                        label: Text(
                          question.difficulty.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getDifficultyColor(question.difficulty),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Question Text Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        question.text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Options',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Options List
                  ...List.generate(question.options.length, (idx) {
                    final isSelected = selectedOption == idx;
                    final letter = idx < optionLetters.length ? optionLetters[idx] : '${idx + 1}';

                    return Card(
                      elevation: isSelected ? 4 : 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surface,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _selectOption(idx),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surfaceContainerHighest,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  question.options[idx],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: selectedOption == null ? null : _handleNextOrSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentIndex == totalQuestions - 1 ? 'Submit Practice' : 'Next Question',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
