import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class NotesScreen extends StatefulWidget {
  final String? initialSubjectId;
  final String? initialTopicId;

  const NotesScreen({
    super.key,
    this.initialSubjectId,
    this.initialTopicId,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late String? _selectedSubjectId;
  late String? _selectedTopicId;
  bool _onlyBookmarked = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSubjectId;
    _selectedTopicId = widget.initialTopicId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNoteBottomSheet(BuildContext context, Note note) {
    context.read<AppProvider>().markNoteRecentlyViewed(note.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: note.type == NoteType.pdf
                              ? Colors.red.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note.type == NoteType.pdf ? 'PDF Note' : 'Text Note',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: note.type == NoteType.pdf
                                ? Colors.red.shade900
                                : Colors.blue.shade900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Consumer<AppProvider>(
                        builder: (_, provider, _) {
                          final isBookmarked = provider.notes
                              .firstWhere((n) => n.id == note.id)
                              .bookmarked;
                          return IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked ? Colors.amber : null,
                            ),
                            onPressed: () {
                              provider.toggleNoteBookmark(note.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    note.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 32),
                  if (note.type == NoteType.pdf)
                    Card(
                      color: Colors.red.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 64,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'PDF Document Placeholder',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              note.content,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'PDF Reader is in preview mode (Demo).'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.remove_red_eye),
                              label: const Text('Open PDF Viewer'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SelectableText(
                      note.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    // Filter notes
    List<Note> filteredNotes = provider.notes.where((n) {
      if (_selectedSubjectId != null && n.subjectId != _selectedSubjectId) {
        return false;
      }
      if (_selectedTopicId != null && n.topicId != _selectedTopicId) {
        return false;
      }
      if (_onlyBookmarked && !n.bookmarked) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = n.title.toLowerCase().contains(q);
        final matchContent = n.content.toLowerCase().contains(q);
        if (!matchTitle && !matchContent) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Study Notes'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes by title or content...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Subjects'),
                  selected: _selectedSubjectId == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSubjectId = null;
                      _selectedTopicId = null;
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
                          _selectedTopicId = null;
                        });
                      },
                    ),
                  );
                }),
                FilterChip(
                  avatar: Icon(
                    _onlyBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                  ),
                  label: const Text('Bookmarked'),
                  selected: _onlyBookmarked,
                  onSelected: (selected) {
                    setState(() {
                      _onlyBookmarked = selected;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Content grouped by Subject -> Topic
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes match your filters',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: provider.subjects.map((subject) {
                      final subjectNotes = filteredNotes
                          .where((n) => n.subjectId == subject.id)
                          .toList();

                      if (subjectNotes.isEmpty) return const SizedBox.shrink();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(
                            subject.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text('${subjectNotes.length} notes available'),
                          children: subject.topics.map((topic) {
                            final topicNotes = subjectNotes
                                .where((n) => n.topicId == topic.id)
                                .toList();

                            if (topicNotes.isEmpty) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    '📌 ${topic.name}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                ...topicNotes.map((note) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: note.type == NoteType.pdf
                                          ? Colors.red.shade100
                                          : Colors.blue.shade100,
                                      child: Icon(
                                        note.type == NoteType.pdf
                                            ? Icons.picture_as_pdf
                                            : Icons.article,
                                        color: note.type == NoteType.pdf
                                            ? Colors.red.shade800
                                            : Colors.blue.shade800,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      note.title,
                                      style: TextStyle(
                                        decoration: note.completed
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      note.type == NoteType.pdf
                                          ? 'PDF Document'
                                          : note.content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            note.completed
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: note.completed
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          tooltip: note.completed
                                              ? 'Completed'
                                              : 'Mark Completed',
                                          onPressed: () {
                                            provider.toggleNoteCompleted(note.id);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            note.bookmarked
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: note.bookmarked
                                                ? Colors.amber
                                                : Colors.grey,
                                          ),
                                          tooltip: 'Bookmark',
                                          onPressed: () {
                                            provider.toggleNoteBookmark(note.id);
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () =>
                                        _openNoteBottomSheet(context, note),
                                  );
                                }),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
