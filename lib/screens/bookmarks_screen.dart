import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'quiz_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  void _openNoteViewer(BuildContext context, Note note) {
    context.read<AppProvider>().markNoteRecentlyViewed(note.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
              if (note.type == NoteType.pdf)
                Card(
                  color: Colors.red.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(width: 12),
                        Text('PDF Viewer Placeholder'),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  note.content,
                  style: theme.textTheme.bodyLarge,
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookmarkedNotes = provider.notes.where((n) => n.bookmarked).toList();
    final bookmarkedQuestions =
        provider.questions.where((q) => q.bookmarked).toList();
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('⭐ Saved Bookmarks'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.note_alt_outlined), text: 'Notes'),
              Tab(icon: Icon(Icons.quiz_outlined), text: 'Questions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Notes Tab
            bookmarkedNotes.isEmpty
                ? const Center(child: Text('No bookmarked notes.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookmarkedNotes.length,
                    itemBuilder: (context, idx) {
                      final note = bookmarkedNotes[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: Icon(
                            note.type == NoteType.pdf
                                ? Icons.picture_as_pdf
                                : Icons.article,
                            color: note.type == NoteType.pdf
                                ? Colors.red
                                : Colors.blue,
                          ),
                          title: Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            note.type == NoteType.pdf
                                ? 'PDF Note'
                                : note.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.bookmark_remove, color: Colors.amber),
                            onPressed: () {
                              provider.toggleNoteBookmark(note.id);
                            },
                          ),
                          onTap: () => _openNoteViewer(context, note),
                        ),
                      );
                    },
                  ),

            // Questions Tab
            bookmarkedQuestions.isEmpty
                ? const Center(child: Text('No bookmarked questions.'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: bookmarkedQuestions.length,
                          itemBuilder: (context, idx) {
                            final q = bookmarkedQuestions[idx];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text('${idx + 1}'),
                                ),
                                title: Text(
                                  q.text,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Correct: ${q.options[q.correctIndex]}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.bookmark_remove,
                                      color: Colors.amber),
                                  onPressed: () {
                                    provider.toggleQuestionBookmark(q.id);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuizScreen(questions: bookmarkedQuestions),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            'Practice Bookmarked Questions (${bookmarkedQuestions.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
