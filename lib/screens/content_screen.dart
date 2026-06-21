import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/database_helper.dart';
import '../models/code_models.dart';
import 'article_list_screen.dart';

import '../widgets/code_num_app_bar.dart';

enum ContentType { title, chapter }

class ContentScreen extends StatelessWidget {
  final String title;
  final ContentType type;
  final int parentId;

  const ContentScreen({
    super.key,
    required this.title,
    required this.type,
    required this.parentId,
  });

  Future<List<dynamic>> _fetchData() {
    if (type == ContentType.title) {
      return DatabaseHelper().getTitles(parentId);
    } else {
      return DatabaseHelper().getChapters(parentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CodeNumAppBar(title: title),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun contenu trouvé'));
          }

          final items = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              String itemTitle = '';
              int itemId = 0;

              if (item is TitleStruct) {
                itemTitle = item.title;
                itemId = item.id!;
              } else if (item is Chapter) {
                itemTitle = item.title;
                itemId = item.id!;
              }

              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    itemTitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () async {
                    if (type == ContentType.title) {
                      final chapters = await DatabaseHelper().getChapters(itemId);
                      if (!context.mounted) return;
                      if (chapters.length == 1 && chapters.first.title.toLowerCase().contains("unique")) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleListScreen(
                              chapterTitle: itemTitle,
                              chapterId: chapters.first.id!,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              title: itemTitle,
                              type: ContentType.chapter,
                              parentId: itemId,
                            ),
                          ),
                        );
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleListScreen(
                            chapterTitle: itemTitle,
                            chapterId: itemId,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ).animate().fadeIn(delay: (30 * (index > 15 ? 15 : index)).ms).slideX(begin: 0.1);
            },
          );
        },
      ),
    );
  }
}
