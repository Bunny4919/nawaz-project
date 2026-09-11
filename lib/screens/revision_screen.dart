import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'bookmarks_screen.dart';
import 'mistake_book_screen.dart';
import 'weak_topics_screen.dart';

class RevisionScreen extends StatelessWidget {
  const RevisionScreen({super.key});

  void _openNoteViewer(BuildContext context, Note note) {
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
    final theme = Theme.of(context);

    final bookmarkedNotesCount = provider.notes.where((n) => n.bookmarked).length;
    final bookmarkedQuestionsCount =
        provider.questions.where((q) => q.bookmarked).length;
    final wrongQuestionsCount = provider.mistakeBook.length;
    final weakTopicsCount = provider.weakTopics.length;
    final recentNotes = provider.recentlyViewedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔄 Revision Hub'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Revision Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Revision Links Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _RevisionCard(
                  title: 'Bookmarked Notes',
                  count: '$bookmarkedNotesCount Saved',
                  icon: Icons.bookmark,
                  color: Colors.amber.shade700,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookmarksScreen(),
                      ),
                    );
                  },
                ),
                _RevisionCard(
                  title: 'Wrong Questions',
                  count: '$wrongQuestionsCount Errors',
                  icon: Icons.highlight_off,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MistakeBookScreen(),
                      ),
                    );
                  },
                ),
                _RevisionCard(
                  title: 'Bookmarked Questions',
                  count: '$bookmarkedQuestionsCount Saved',
                  icon: Icons.star,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookmarksScreen(),
                      ),
                    );
                  },
                ),
                _RevisionCard(
                  title: 'Weak Topics',
                  count: '$weakTopicsCount Focus Areas',
                  icon: Icons.warning_amber,
                  color: Colors.deepOrange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WeakTopicsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recently Viewed Notes Section
            Text(
              'Recently Viewed Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            recentNotes.isEmpty
                ? Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'No recently viewed notes. Tap any note in the Notes section to view it here.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentNotes.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final note = recentNotes[index];
                        return ListTile(
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
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _openNoteViewer(context, note),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _RevisionCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RevisionCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
