enum NoteType { pdf, text }

enum Difficulty { easy, medium, hard }

class Topic {
  final String id;
  final String name;
  final String subjectId;

  const Topic({
    required this.id,
    required this.name,
    required this.subjectId,
  });
}

class Subject {
  final String id;
  final String name;
  final List<Topic> topics;

  const Subject({
    required this.id,
    required this.name,
    required this.topics,
  });
}

class Note {
  final String id;
  final String subjectId;
  final String topicId;
  final String title;
  final NoteType type;
  final String content;
  bool bookmarked;
  bool completed;

  Note({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.title,
    required this.type,
    required this.content,
    this.bookmarked = false,
    this.completed = false,
  });
}

class Question {
  final String id;
  final String subjectId;
  final String topicId;
  final Difficulty difficulty;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  bool bookmarked;

  Question({
    required this.id,
    required this.subjectId,
    required this.topicId,
    required this.difficulty,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.bookmarked = false,
  });
}

class MockTest {
  final String id;
  final String title;
  final int durationMinutes;
  final Map<String, int> subjectQuestionCounts;

  const MockTest({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.subjectQuestionCounts,
  });

  int get totalQuestions =>
      subjectQuestionCounts.values.fold(0, (sum, count) => sum + count);
}

class MistakeEntry {
  final Question question;
  final int selectedIndex;
  final DateTime date;

  MistakeEntry({
    required this.question,
    required this.selectedIndex,
    required this.date,
  });
}

class StatCounter {
  int attempted;
  int correct;

  StatCounter({
    this.attempted = 0,
    this.correct = 0,
  });

  int get wrong => attempted - correct;

  double get accuracy => attempted == 0 ? 0.0 : (correct / attempted) * 100;
}

class AnsweredQuestion {
  final Question question;
  int selectedIndex;
  bool markedForReview;

  AnsweredQuestion({
    required this.question,
    this.selectedIndex = -1,
    this.markedForReview = false,
  });

  bool get isAnswered => selectedIndex >= 0;
  bool get isCorrect => selectedIndex == question.correctIndex;
}
