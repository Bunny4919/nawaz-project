import '../models/models.dart';

final List<Subject> dummySubjects = [
  const Subject(
    id: 'sub_aptitude',
    name: 'Aptitude',
    topics: [
      Topic(id: 'top_percentages', name: 'Percentages', subjectId: 'sub_aptitude'),
      Topic(id: 'top_profit_loss', name: 'Profit & Loss', subjectId: 'sub_aptitude'),
      Topic(id: 'top_time_work', name: 'Time & Work', subjectId: 'sub_aptitude'),
    ],
  ),
  const Subject(
    id: 'sub_reasoning',
    name: 'Reasoning',
    topics: [
      Topic(id: 'top_blood_relations', name: 'Blood Relations', subjectId: 'sub_reasoning'),
      Topic(id: 'top_number_series', name: 'Number Series', subjectId: 'sub_reasoning'),
    ],
  ),
  const Subject(
    id: 'sub_english',
    name: 'English',
    topics: [
      Topic(id: 'top_grammar', name: 'Grammar', subjectId: 'sub_english'),
      Topic(id: 'top_vocabulary', name: 'Vocabulary', subjectId: 'sub_english'),
    ],
  ),
  const Subject(
    id: 'sub_programming',
    name: 'Programming',
    topics: [
      Topic(id: 'top_python', name: 'Python', subjectId: 'sub_programming'),
      Topic(id: 'top_sql', name: 'SQL', subjectId: 'sub_programming'),
    ],
  ),
];

final List<Note> dummyNotes = [
  // Aptitude - Percentages
  Note(
    id: 'note_1',
    subjectId: 'sub_aptitude',
    topicId: 'top_percentages',
    title: 'Percentage Concepts & Formulae',
    type: NoteType.text,
    content:
        'Percentage means "per hundred".\nFormula: (Value / Total Value) * 100.\n'
        'Key Fractions:\n1/2 = 50%\n1/3 = 33.33%\n1/4 = 25%\n1/5 = 20%\n1/6 = 16.67%\n'
        'Percentage Increase = [(New Value - Original Value) / Original Value] * 100.',
    bookmarked: true,
  ),
  Note(
    id: 'note_2',
    subjectId: 'sub_aptitude',
    topicId: 'top_percentages',
    title: 'Advanced Percentages Guide PDF',
    type: NoteType.pdf,
    content: 'https://example.com/notes/percentages_advanced.pdf',
  ),

  // Aptitude - Profit & Loss
  Note(
    id: 'note_3',
    subjectId: 'sub_aptitude',
    topicId: 'top_profit_loss',
    title: 'Cost Price vs Selling Price Summary',
    type: NoteType.text,
    content:
        'Cost Price (CP): Price at which an article is bought.\n'
        'Selling Price (SP): Price at which an article is sold.\n'
        'Profit = SP - CP (when SP > CP)\n'
        'Loss = CP - SP (when CP > SP)\n'
        'Profit % = (Profit / CP) * 100\n'
        'Loss % = (Loss / CP) * 100',
  ),

  // Aptitude - Time & Work
  Note(
    id: 'note_4',
    subjectId: 'sub_aptitude',
    topicId: 'top_time_work',
    title: 'Time & Work Shortcuts PDF',
    type: NoteType.pdf,
    content: 'https://example.com/notes/time_and_work.pdf',
  ),
  Note(
    id: 'note_5',
    subjectId: 'sub_aptitude',
    topicId: 'top_time_work',
    title: 'Efficiency & Rate Method',
    type: NoteType.text,
    content:
        'If A can do a work in X days, A\'s 1 day work = 1/X.\n'
        'If A and B work together, 1 day work = (1/X) + (1/Y).\n'
        'Total Work = Efficiency * Time.',
  ),

  // Reasoning - Blood Relations
  Note(
    id: 'note_6',
    subjectId: 'sub_reasoning',
    topicId: 'top_blood_relations',
    title: 'Family Tree Diagrams & Notations',
    type: NoteType.text,
    content:
        'Symbols:\n(+) Male, (-) Female\n(=) Married Couple\n(|) Parent-Child\n'
        'Paternal = Father\'s side\nMaternal = Mother\'s side\n'
        'Nephew = Brother/Sister\'s son\nNiece = Brother/Sister\'s daughter.',
  ),

  // Reasoning - Number Series
  Note(
    id: 'note_7',
    subjectId: 'sub_reasoning',
    topicId: 'top_number_series',
    title: 'Pattern Identification Rules',
    type: NoteType.text,
    content:
        'Common Patterns:\n1. Arithmetic Progression (+d, -d)\n'
        '2. Geometric Progression (*r, /r)\n3. Prime Numbers & Squares/Cubes\n'
        '4. Alternate Series (two series combined)\n5. Fibonacci Sequence.',
  ),

  // English - Grammar
  Note(
    id: 'note_8',
    subjectId: 'sub_english',
    topicId: 'top_grammar',
    title: 'Subject-Verb Agreement PDF',
    type: NoteType.pdf,
    content: 'https://example.com/notes/grammar_rules.pdf',
    bookmarked: true,
  ),
  Note(
    id: 'note_9',
    subjectId: 'sub_english',
    topicId: 'top_grammar',
    title: 'Tenses Quick Reference',
    type: NoteType.text,
    content:
        '1. Present Simple: Habitual actions (I play).\n'
        '2. Present Continuous: Happening now (I am playing).\n'
        '3. Present Perfect: Completed action with present relevance (I have played).\n'
        '4. Past Simple: Finished action (I played).',
  ),

  // English - Vocabulary
  Note(
    id: 'note_10',
    subjectId: 'sub_english',
    topicId: 'top_vocabulary',
    title: 'High-Frequency Roots & Prefixes',
    type: NoteType.text,
    content:
        'Bene = Good (Beneficial, Benevolent)\n'
        'Mal = Bad (Malevolent, Malicious)\n'
        'Chron = Time (Chronological, Synchronize)\n'
        'Path = Feeling (Empathy, Apathy)',
  ),

  // Programming - Python
  Note(
    id: 'note_11',
    subjectId: 'sub_programming',
    topicId: 'top_python',
    title: 'Python Data Structures Essentials',
    type: NoteType.text,
    content:
        'Lists: Mutable, ordered [1, 2, 3]\n'
        'Tuples: Immutable, ordered (1, 2, 3)\n'
        'Sets: Mutable, unordered, unique {1, 2, 3}\n'
        'Dicts: Key-value pairs {"key": "value"}\n'
        'List Comprehension: [x**2 for x in range(10)]',
    bookmarked: true,
  ),

  // Programming - SQL
  Note(
    id: 'note_12',
    subjectId: 'sub_programming',
    topicId: 'top_sql',
    title: 'SQL Joins Cheat Sheet PDF',
    type: NoteType.pdf,
    content: 'https://example.com/notes/sql_joins.pdf',
  ),
];

final List<Question> dummyQuestions = [
  // Aptitude - Percentages
  Question(
    id: 'q_1',
    subjectId: 'sub_aptitude',
    topicId: 'top_percentages',
    difficulty: Difficulty.easy,
    text: 'What is 15% of 200?',
    options: ['20', '25', '30', '35'],
    correctIndex: 2,
    explanation: '15% of 200 = (15 / 100) * 200 = 30.',
    bookmarked: true,
  ),
  Question(
    id: 'q_2',
    subjectId: 'sub_aptitude',
    topicId: 'top_percentages',
    difficulty: Difficulty.medium,
    text: 'If a salary increases from \$400 to \$500, what is the percentage increase?',
    options: ['20%', '25%', '30%', '15%'],
    correctIndex: 1,
    explanation: 'Increase = 500 - 400 = 100. Percentage Increase = (100 / 400) * 100 = 25%.',
  ),
  Question(
    id: 'q_3',
    subjectId: 'sub_aptitude',
    topicId: 'top_percentages',
    difficulty: Difficulty.hard,
    text: 'A number is increased by 20% and then decreased by 20%. What is the net change?',
    options: ['No change', '4% increase', '4% decrease', '2% decrease'],
    correctIndex: 2,
    explanation: 'Let original = 100. After +20% = 120. After -20% = 120 * 0.8 = 96. Net change = -4%.',
  ),

  // Aptitude - Profit & Loss
  Question(
    id: 'q_4',
    subjectId: 'sub_aptitude',
    topicId: 'top_profit_loss',
    difficulty: Difficulty.easy,
    text: 'An item bought for \$80 is sold for \$100. What is the profit percentage?',
    options: ['20%', '25%', '30%', '15%'],
    correctIndex: 1,
    explanation: 'Profit = 100 - 80 = 20. Profit % = (20 / 80) * 100 = 25%.',
  ),
  Question(
    id: 'q_5',
    subjectId: 'sub_aptitude',
    topicId: 'top_profit_loss',
    difficulty: Difficulty.medium,
    text: 'If selling price is doubled, the profit triples. Find the profit percentage.',
    options: ['66.66%', '100%', '120%', '150%'],
    correctIndex: 1,
    explanation: 'Let CP = x, SP = y. Profit P = y - x. New SP = 2y, New Profit = 3P = 2y - x. 3(y - x) = 2y - x => y = 2x. Profit = x. Profit % = 100%.',
  ),

  // Aptitude - Time & Work
  Question(
    id: 'q_6',
    subjectId: 'sub_aptitude',
    topicId: 'top_time_work',
    difficulty: Difficulty.medium,
    text: 'A can do a job in 10 days, and B can do it in 15 days. How long will they take working together?',
    options: ['5 days', '6 days', '7.5 days', '8 days'],
    correctIndex: 1,
    explanation: '1/10 + 1/15 = (3 + 2)/30 = 5/30 = 1/6. So working together takes 6 days.',
  ),
  Question(
    id: 'q_7',
    subjectId: 'sub_aptitude',
    topicId: 'top_time_work',
    difficulty: Difficulty.hard,
    text: 'A and B together take 12 days. A alone takes 20 days. How long does B alone take?',
    options: ['25 days', '30 days', '35 days', '40 days'],
    correctIndex: 1,
    explanation: '1/B = 1/12 - 1/20 = (5 - 3)/60 = 2/60 = 1/30. B takes 30 days.',
  ),

  // Reasoning - Blood Relations
  Question(
    id: 'q_8',
    subjectId: 'sub_reasoning',
    topicId: 'top_blood_relations',
    difficulty: Difficulty.easy,
    text: 'Pointing to a man, a woman said, "His mother is the only daughter of my mother." How is the woman related to the man?',
    options: ['Sister', 'Mother', 'Aunt', 'Daughter'],
    correctIndex: 1,
    explanation: 'Only daughter of woman\'s mother is the woman herself. So the man\'s mother is the woman.',
  ),
  Question(
    id: 'q_9',
    subjectId: 'sub_reasoning',
    topicId: 'top_blood_relations',
    difficulty: Difficulty.medium,
    text: 'If A + B means A is the brother of B, A - B means A is the sister of B. What does P + Q - R mean?',
    options: ['P is brother of R', 'P is sister of R', 'P is father of R', 'P is uncle of R'],
    correctIndex: 0,
    explanation: 'P is brother of Q, and Q is sister of R. Therefore P is the brother of R.',
  ),

  // Reasoning - Number Series
  Question(
    id: 'q_10',
    subjectId: 'sub_reasoning',
    topicId: 'top_number_series',
    difficulty: Difficulty.easy,
    text: 'Complete the series: 2, 4, 8, 16, ?',
    options: ['24', '30', '32', '64'],
    correctIndex: 2,
    explanation: 'Each number is multiplied by 2. 16 * 2 = 32.',
  ),
  Question(
    id: 'q_11',
    subjectId: 'sub_reasoning',
    topicId: 'top_number_series',
    difficulty: Difficulty.hard,
    text: 'Find the next number: 3, 5, 9, 17, 33, ?',
    options: ['65', '55', '60', '49'],
    correctIndex: 0,
    explanation: 'Differences are 2, 4, 8, 16. Next difference is 32. 33 + 32 = 65.',
    bookmarked: true,
  ),

  // English - Grammar
  Question(
    id: 'q_12',
    subjectId: 'sub_english',
    topicId: 'top_grammar',
    difficulty: Difficulty.easy,
    text: 'Choose the correct verb: Neither of the answers _____ correct.',
    options: ['is', 'are', 'were', 'have'],
    correctIndex: 0,
    explanation: '"Neither" takes a singular verb, so "is" is correct.',
  ),
  Question(
    id: 'q_13',
    subjectId: 'sub_english',
    topicId: 'top_grammar',
    difficulty: Difficulty.medium,
    text: 'Identify the sentence with correct punctuation:',
    options: [
      'Its a beautiful day outside.',
      'It\'s a beautiful day outside.',
      'Its\' a beautiful day outside.',
      'It is a beautiful day, outside'
    ],
    correctIndex: 1,
    explanation: '"It\'s" is the contraction for "It is".',
  ),

  // English - Vocabulary
  Question(
    id: 'q_14',
    subjectId: 'sub_english',
    topicId: 'top_vocabulary',
    difficulty: Difficulty.easy,
    text: 'What is the synonym of "Benevolent"?',
    options: ['Malevolent', 'Kind', 'Cruel', 'Greedy'],
    correctIndex: 1,
    explanation: 'Benevolent means well-meaning and kindly.',
  ),
  Question(
    id: 'q_15',
    subjectId: 'sub_english',
    topicId: 'top_vocabulary',
    difficulty: Difficulty.hard,
    text: 'What is the antonym of "Ephemeral"?',
    options: ['Transient', 'Fleeting', 'Permanent', 'Short-lived'],
    correctIndex: 2,
    explanation: 'Ephemeral means lasting a very short time; permanent is the antonym.',
  ),

  // Programming - Python
  Question(
    id: 'q_16',
    subjectId: 'sub_programming',
    topicId: 'top_python',
    difficulty: Difficulty.easy,
    text: 'What is the output of print(type([])) in Python?',
    options: ['<class \'tuple\'>', '<class \'list\'>', '<class \'set\'>', '<class \'dict\'>'],
    correctIndex: 1,
    explanation: 'Square brackets [] define a list in Python.',
  ),
  Question(
    id: 'q_17',
    subjectId: 'sub_programming',
    topicId: 'top_python',
    difficulty: Difficulty.medium,
    text: 'Which keyword is used to create a function in Python?',
    options: ['fun', 'function', 'def', 'create'],
    correctIndex: 2,
    explanation: '"def" is the keyword used to define functions in Python.',
  ),
  Question(
    id: 'q_18',
    subjectId: 'sub_programming',
    topicId: 'top_python',
    difficulty: Difficulty.hard,
    text: 'What does the list comprehension [x for x in range(5) if x % 2 == 0] evaluate to?',
    options: ['[0, 1, 2, 3, 4]', '[0, 2, 4]', '[1, 3]', '[2, 4]'],
    correctIndex: 1,
    explanation: 'range(5) gives 0..4. Even numbers are 0, 2, and 4.',
  ),

  // Programming - SQL
  Question(
    id: 'q_19',
    subjectId: 'sub_programming',
    topicId: 'top_sql',
    difficulty: Difficulty.easy,
    text: 'Which SQL statement is used to retrieve data from a database?',
    options: ['GET', 'OPEN', 'EXTRACT', 'SELECT'],
    correctIndex: 3,
    explanation: 'SELECT is used to query data from a database table.',
  ),
  Question(
    id: 'q_20',
    subjectId: 'sub_programming',
    topicId: 'top_sql',
    difficulty: Difficulty.medium,
    text: 'Which SQL clause is used to filter records after aggregation with GROUP BY?',
    options: ['WHERE', 'HAVING', 'FILTER', 'ORDER BY'],
    correctIndex: 1,
    explanation: 'HAVING is used to filter aggregated results created by GROUP BY.',
  ),
];

final List<MockTest> dummyMockTests = [
  const MockTest(
    id: 'mock_1',
    title: 'General Aptitude & Reasoning Speed Test',
    durationMinutes: 15,
    subjectQuestionCounts: {
      'sub_aptitude': 5,
      'sub_reasoning': 3,
    },
  ),
  const MockTest(
    id: 'mock_2',
    title: 'Full Subject Grand Mock Test',
    durationMinutes: 30,
    subjectQuestionCounts: {
      'sub_aptitude': 4,
      'sub_reasoning': 3,
      'sub_english': 3,
      'sub_programming': 4,
    },
  ),
  const MockTest(
    id: 'mock_3',
    title: 'Tech & Code Specialist Mock',
    durationMinutes: 20,
    subjectQuestionCounts: {
      'sub_programming': 5,
      'sub_english': 3,
    },
  ),
];
