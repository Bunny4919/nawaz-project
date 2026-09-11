import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';
import 'notes_screen.dart';
import 'quiz_setup_screen.dart';
import 'mock_test_list_screen.dart';
import 'performance_screen.dart';
import 'mistake_book_screen.dart';
import 'bookmarks_screen.dart';
import 'weak_topics_screen.dart';
import 'revision_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final username = provider.username ?? 'Student';
    final theme = Theme.of(context);

    final tiles = [
      _DashboardTileData(
        title: '📚 Notes',
        subtitle: '${provider.notes.length} Study Notes',
        color: Colors.indigo.shade100,
        iconColor: Colors.indigo,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotesScreen()),
        ),
      ),
      _DashboardTileData(
        title: '🧠 Practice Quiz',
        subtitle: '6 Custom Modes',
        color: Colors.purple.shade100,
        iconColor: Colors.purple,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizSetupScreen()),
        ),
      ),
      _DashboardTileData(
        title: '📝 Mock Tests',
        subtitle: '${provider.mockTests.length} Full Length Tests',
        color: Colors.blue.shade100,
        iconColor: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MockTestListScreen()),
        ),
      ),
      _DashboardTileData(
        title: '📊 Performance',
        subtitle: 'Accuracy ${provider.overallAccuracy.toStringAsFixed(0)}%',
        color: Colors.teal.shade100,
        iconColor: Colors.teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PerformanceScreen()),
        ),
      ),
      _DashboardTileData(
        title: '❌ Mistake Book',
        subtitle: '${provider.mistakeBook.length} Saved Errors',
        color: Colors.red.shade100,
        iconColor: Colors.red,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MistakeBookScreen()),
        ),
      ),
      _DashboardTileData(
        title: '⭐ Bookmarks',
        subtitle:
            '${provider.notes.where((n) => n.bookmarked).length} Notes, ${provider.questions.where((q) => q.bookmarked).length} Questions',
        color: Colors.amber.shade100,
        iconColor: Colors.amber.shade900,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookmarksScreen()),
        ),
      ),
      _DashboardTileData(
        title: '⚠️ Weak Topics',
        subtitle: '${provider.weakTopics.length} Focus Areas',
        color: Colors.orange.shade100,
        iconColor: Colors.deepOrange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WeakTopicsScreen()),
        ),
      ),
      _DashboardTileData(
        title: '🔄 Revision',
        subtitle: 'Quick Review Hub',
        color: Colors.green.shade100,
        iconColor: Colors.green.shade800,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RevisionScreen()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              provider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: tiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final tile = tiles[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.colorScheme.surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: tile.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tile.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tile.title.split(' ').first,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        tile.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tile.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardTileData {
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  _DashboardTileData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });
}
