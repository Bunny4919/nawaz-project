import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'mock_test_result_screen.dart';

class MockTestScreen extends StatefulWidget {
  final MockTest mockTest;
  final List<Question> questions;

  const MockTestScreen({
    super.key,
    required this.mockTest,
    required this.questions,
  });

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  int _currentIndex = 0;

  late List<AnsweredQuestion> _answeredList;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.mockTest.durationMinutes * 60;
    _answeredList = widget.questions
        .map((q) => AnsweredQuestion(question: q))
        .toList();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _submitTest(autoSubmitted: true);
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _submitTest({bool autoSubmitted = false}) {
    if (_isSubmitting) return;
    _isSubmitting = true;
    _timer?.cancel();

    final provider = context.read<AppProvider>();

    for (var aq in _answeredList) {
      if (aq.isAnswered) {
        provider.recordAnswer(aq.question, aq.selectedIndex);
      }
    }

    provider.completeQuiz(isMockTest: true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MockTestResultScreen(
          mockTest: widget.mockTest,
          questions: widget.questions,
          answeredState: _answeredList,
          wasAutoSubmitted: autoSubmitted,
        ),
      ),
    );
  }

  void _confirmManualSubmit() {
    final unanswered = _answeredList.where((a) => !a.isAnswered).length;
    final flagged = _answeredList.where((a) => a.markedForReview).length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Mock Test?'),
          content: Text(
            'You have $unanswered unanswered questions and $flagged marked for review.\n\nAre you sure you want to finish?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Test'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitTest(autoSubmitted: false);
              },
              child: const Text('Submit Now'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentAq = _answeredList[_currentIndex];
    final currentQ = currentAq.question;
    final isTimerWarning = _remainingSeconds < 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmManualSubmit();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.mockTest.title),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isTimerWarning
                    ? Colors.red.shade100
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.alarm,
                    size: 18,
                    color: isTimerWarning
                        ? Colors.red
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTimer(_remainingSeconds),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isTimerWarning
                          ? Colors.red.shade900
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Numbered Strip Palette
            Container(
              height: 60,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: _answeredList.length,
                itemBuilder: (context, idx) {
                  final item = _answeredList[idx];
                  final isCurrent = idx == _currentIndex;

                  Color bg = Colors.grey.shade300;
                  Color fg = Colors.black87;

                  if (item.markedForReview) {
                    bg = Colors.purple.shade300;
                    fg = Colors.white;
                  } else if (item.isAnswered) {
                    bg = Colors.green.shade500;
                    fg = Colors.white;
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = idx;
                      });
                    },
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: fg,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${widget.questions.length}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        FilterChip(
                          avatar: Icon(
                            currentAq.markedForReview
                                ? Icons.flag
                                : Icons.flag_outlined,
                            size: 16,
                            color: currentAq.markedForReview
                                ? Colors.purple
                                : null,
                          ),
                          label: Text(
                            currentAq.markedForReview
                                ? 'Flagged'
                                : 'Mark for Review',
                          ),
                          selected: currentAq.markedForReview,
                          onSelected: (selected) {
                            setState(() {
                              currentAq.markedForReview = selected;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          currentQ.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    ...List.generate(currentQ.options.length, (idx) {
                      final isSelected = currentAq.selectedIndex == idx;
                      const letters = ['A', 'B', 'C', 'D'];

                      return Card(
                        elevation: isSelected ? 3 : 1,
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
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            child: Text(
                              letters[idx],
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(currentQ.options[idx]),
                          onTap: () {
                            setState(() {
                              currentAq.selectedIndex = idx;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation bar at bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  const Spacer(),
                  if (_currentIndex < widget.questions.length - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex++;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _confirmManualSubmit,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Submit Test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
