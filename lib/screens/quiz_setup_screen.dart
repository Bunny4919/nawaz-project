import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'quiz_screen.dart';

enum QuizMode {
  subjectWise('Subject-wise', 'Practice questions from a specific subject'),
  topicWise('Topic-wise', 'Target a particular topic in depth'),
  random('Random Practice', 'Mixed questions from all subjects'),
  weakTopic('Weak Topics', 'Focus on topics with accuracy under 60%'),
  wrongAnswers('Wrong Answers', 'Re-attempt questions from Mistake Book'),
  bookmarked('Bookmarked', 'Practice your saved questions');

  final String label;
  final String description;
  const QuizMode(this.label, this.description);
}

class QuizSetupScreen extends StatefulWidget {
  final QuizMode? initialMode;
  final String? initialSubjectId;
  final String? initialTopicId;

  const QuizSetupScreen({
    super.key,
    this.initialMode,
    this.initialSubjectId,
    this.initialTopicId,
  });

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  late QuizMode _selectedMode;
  String? _selectedSubjectId;
  String? _selectedTopicId;
  Difficulty? _selectedDifficulty; // null means Mixed
  double _questionCount = 10;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode ?? QuizMode.subjectWise;
    _selectedSubjectId = widget.initialSubjectId;
    _selectedTopicId = widget.initialTopicId;
  }

  void _startQuiz() {
    final provider = context.read<AppProvider>();

    bool onlyWrong = _selectedMode == QuizMode.wrongAnswers;
    bool onlyBookmarked = _selectedMode == QuizMode.bookmarked;
    bool onlyWeakTopics = _selectedMode == QuizMode.weakTopic;

    String? filterSubjectId;
    String? filterTopicId;

    if (_selectedMode == QuizMode.subjectWise || _selectedMode == QuizMode.topicWise) {
      filterSubjectId = _selectedSubjectId;
    }
    if (_selectedMode == QuizMode.topicWise) {
      filterTopicId = _selectedTopicId;
    }

    final quizQuestions = provider.buildFilteredQuizQuestions(
      subjectId: filterSubjectId,
      topicId: filterTopicId,
      difficulty: _selectedDifficulty,
      onlyWrong: onlyWrong,
      onlyBookmarked: onlyBookmarked,
      onlyWeakTopics: onlyWeakTopics,
      limit: _questionCount.round(),
      shuffle: true,
    );

    if (quizQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No questions found matching your selected criteria!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(questions: quizQuestions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    // Prepare dropdown options
    final subjects = provider.subjects;
    final selectedSubject = subjects.firstWhere(
      (s) => s.id == _selectedSubjectId,
      orElse: () => subjects.first,
    );

    final topics = selectedSubject.topics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Practice Quiz Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Practice Mode',
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
              child: Column(
                children: QuizMode.values.map((mode) {
                  // ignore: deprecated_member_use
                  return RadioListTile<QuizMode>(
                    value: mode,
                    // ignore: deprecated_member_use
                    groupValue: _selectedMode,
                    title: Text(
                      mode.label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(mode.description),
                    // ignore: deprecated_member_use
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMode = val;
                          if (_selectedSubjectId == null && subjects.isNotEmpty) {
                            _selectedSubjectId = subjects.first.id;
                          }
                          if (_selectedTopicId == null &&
                              subjects.first.topics.isNotEmpty) {
                            _selectedTopicId = subjects.first.topics.first.id;
                          }
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Subject / Topic Dropdowns
            if (_selectedMode == QuizMode.subjectWise ||
                _selectedMode == QuizMode.topicWise) ...[
              Text(
                'Select Subject',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedSubjectId ?? (subjects.isNotEmpty ? subjects.first.id : null),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: subjects.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSubjectId = val;
                    final newSub = subjects.firstWhere((s) => s.id == val);
                    _selectedTopicId = newSub.topics.isNotEmpty ? newSub.topics.first.id : null;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            if (_selectedMode == QuizMode.topicWise) ...[
              Text(
                'Select Topic',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedTopicId ?? (topics.isNotEmpty ? topics.first.id : null),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: topics.map((t) {
                  return DropdownMenuItem(
                    value: t.id,
                    child: Text(t.name),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTopicId = val;
                  });
                },
              ),
              const SizedBox(height: 20),
            ],

            // Difficulty Chips
            Text(
              'Difficulty Level',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Mixed'),
                  selected: _selectedDifficulty == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDifficulty = null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Easy'),
                  selected: _selectedDifficulty == Difficulty.easy,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDifficulty = Difficulty.easy);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Medium'),
                  selected: _selectedDifficulty == Difficulty.medium,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDifficulty = Difficulty.medium);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Hard'),
                  selected: _selectedDifficulty == Difficulty.hard,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDifficulty = Difficulty.hard);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question Count Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Number of Questions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_questionCount.round()} Questions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Slider(
              value: _questionCount,
              min: 5,
              max: 20,
              divisions: 15,
              label: '${_questionCount.round()}',
              onChanged: (val) {
                setState(() {
                  _questionCount = val;
                });
              },
            ),
            const SizedBox(height: 24),

            // Start Practice Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _startQuiz,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Start Practice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
