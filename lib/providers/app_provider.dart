import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/dummy_data.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  final List<Subject> _subjects = List.from(dummySubjects);
  final List<Note> _notes = List.from(dummyNotes);
  final List<Question> _questions = List.from(dummyQuestions);
  final List<MockTest> _mockTests = List.from(dummyMockTests);

  String? _username;
  bool _isLoggedIn = false;

  final List<MistakeEntry> _mistakeBook = [];
  final List<String> _recentlyViewedNoteIds = [];

  int _quizzesCompleted = 0;
  int _mockTestsCompleted = 0;
  int _totalAttempted = 0;
  int _totalCorrect = 0;
  int _totalWrong = 0;

  final Map<String, StatCounter> _topicStats = {};
  final Map<String, StatCounter> _subjectStats = {};

  AppProvider() {
    // Initialize stats for subjects and topics
    for (var subject in _subjects) {
      _subjectStats[subject.id] = StatCounter();
      for (var topic in subject.topics) {
        _topicStats[topic.id] = StatCounter();
      }
    }
  }

  // Getters
  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<Note> get notes => List.unmodifiable(_notes);
  List<Question> get questions => List.unmodifiable(_questions);
  List<MockTest> get mockTests => List.unmodifiable(_mockTests);

  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;

  List<MistakeEntry> get mistakeBook => List.unmodifiable(_mistakeBook);
  List<String> get recentlyViewedNoteIds => List.unmodifiable(_recentlyViewedNoteIds);

  List<Note> get recentlyViewedNotes {
    final result = <Note>[];
    for (var id in _recentlyViewedNoteIds.reversed) {
      final noteIndex = _notes.indexWhere((n) => n.id == id);
      if (noteIndex != -1) {
        result.add(_notes[noteIndex]);
      }
    }
    return result;
  }

  int get quizzesCompleted => _quizzesCompleted;
  int get mockTestsCompleted => _mockTestsCompleted;
  int get totalAttempted => _totalAttempted;
  int get totalCorrect => _totalCorrect;
  int get totalWrong => _totalWrong;

  Map<String, StatCounter> get topicStats => Map.unmodifiable(_topicStats);
  Map<String, StatCounter> get subjectStats => Map.unmodifiable(_subjectStats);

  // Computed Getters
  double get overallAccuracy =>
      _totalAttempted == 0 ? 0.0 : (_totalCorrect / _totalAttempted) * 100;

  List<Topic> get weakTopics {
    final allTopics = <Topic>[];
    for (var sub in _subjects) {
      allTopics.addAll(sub.topics);
    }

    final weak = allTopics.where((t) {
      final stat = _topicStats[t.id];
      if (stat == null || stat.attempted == 0) return false;
      return stat.accuracy < 60.0;
    }).toList();

    weak.sort((a, b) {
      final accA = _topicStats[a.id]?.accuracy ?? 0.0;
      final accB = _topicStats[b.id]?.accuracy ?? 0.0;
      return accA.compareTo(accB);
    });

    return weak;
  }

  Subject? get strongestSubject {
    Subject? best;
    double bestAcc = -1.0;

    for (var sub in _subjects) {
      final stat = _subjectStats[sub.id];
      if (stat != null && stat.attempted > 0) {
        if (stat.accuracy > bestAcc) {
          bestAcc = stat.accuracy;
          best = sub;
        }
      }
    }

    return best;
  }

  Subject? get weakestSubject {
    Subject? worst;
    double worstAcc = 101.0;

    for (var sub in _subjects) {
      final stat = _subjectStats[sub.id];
      if (stat != null && stat.attempted > 0) {
        if (stat.accuracy < worstAcc) {
          worstAcc = stat.accuracy;
          worst = sub;
        }
      }
    }

    return worst;
  }

  // Auth Methods
  void login(String name, String password) {
    _username = name.isEmpty ? 'User' : name;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Note Methods
  void toggleNoteBookmark(String noteId) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index].bookmarked = !_notes[index].bookmarked;
      notifyListeners();
    }
  }

  void toggleNoteCompleted(String noteId) {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      _notes[index].completed = !_notes[index].completed;
      notifyListeners();
    }
  }

  void markNoteRecentlyViewed(String noteId) {
    _recentlyViewedNoteIds.remove(noteId);
    _recentlyViewedNoteIds.add(noteId);
    if (_recentlyViewedNoteIds.length > 10) {
      _recentlyViewedNoteIds.removeAt(0);
    }
    notifyListeners();
  }

  // Question Methods
  void toggleQuestionBookmark(String questionId) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index != -1) {
      _questions[index].bookmarked = !_questions[index].bookmarked;
      notifyListeners();
    }
  }

  // Quiz & Test Building Methods
  List<Question> buildFilteredQuizQuestions({
    String? subjectId,
    String? topicId,
    Difficulty? difficulty,
    bool onlyWrong = false,
    bool onlyBookmarked = false,
    bool onlyWeakTopics = false,
    int limit = 10,
    bool shuffle = true,
  }) {
    List<Question> filtered = List.from(_questions);

    if (subjectId != null && subjectId.isNotEmpty) {
      filtered = filtered.where((q) => q.subjectId == subjectId).toList();
    }

    if (topicId != null && topicId.isNotEmpty) {
      filtered = filtered.where((q) => q.topicId == topicId).toList();
    }

    if (difficulty != null) {
      filtered = filtered.where((q) => q.difficulty == difficulty).toList();
    }

    if (onlyWrong) {
      final wrongQuestionIds = _mistakeBook.map((m) => m.question.id).toSet();
      filtered = filtered.where((q) => wrongQuestionIds.contains(q.id)).toList();
    }

    if (onlyBookmarked) {
      filtered = filtered.where((q) => q.bookmarked).toList();
    }

    if (onlyWeakTopics) {
      final weakTopicIds = weakTopics.map((t) => t.id).toSet();
      filtered = filtered.where((q) => weakTopicIds.contains(q.topicId)).toList();
    }

    if (shuffle) {
      filtered.shuffle(Random());
    }

    if (limit > 0 && filtered.length > limit) {
      filtered = filtered.sublist(0, limit);
    }

    return filtered;
  }

  List<Question> buildMockTestQuestions(MockTest test) {
    final List<Question> result = [];
    final random = Random();

    test.subjectQuestionCounts.forEach((subjectId, count) {
      final available = _questions.where((q) => q.subjectId == subjectId).toList();
      available.shuffle(random);
      result.addAll(available.take(count));
    });

    result.shuffle(random);
    return result;
  }

  // Stats & Answer Recording
  void recordAnswer(Question question, int selectedIndex) {
    _totalAttempted++;

    final isCorrect = selectedIndex == question.correctIndex;
    if (isCorrect) {
      _totalCorrect++;
    } else {
      _totalWrong++;
      _mistakeBook.add(MistakeEntry(
        question: question,
        selectedIndex: selectedIndex,
        date: DateTime.now(),
      ));
    }

    // Update topic stat
    _topicStats.putIfAbsent(question.topicId, () => StatCounter());
    _topicStats[question.topicId]!.attempted++;
    if (isCorrect) {
      _topicStats[question.topicId]!.correct++;
    }

    // Update subject stat
    _subjectStats.putIfAbsent(question.subjectId, () => StatCounter());
    _subjectStats[question.subjectId]!.attempted++;
    if (isCorrect) {
      _subjectStats[question.subjectId]!.correct++;
    }

    notifyListeners();
  }

  void completeQuiz({bool isMockTest = false}) {
    if (isMockTest) {
      _mockTestsCompleted++;
    } else {
      _quizzesCompleted++;
    }
    notifyListeners();
  }
}
