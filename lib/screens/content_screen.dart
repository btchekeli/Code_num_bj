import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/database_helper.dart';
import '../models/code_models.dart';
import 'article_list_screen.dart';
import '../widgets/code_num_app_bar.dart';

enum ContentType { title, chapter, section }

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

  Future<List<dynamic>> _fetchData() async {
    if (type == ContentType.title) {
      return await DatabaseHelper().getTitles(parentId);
    } else if (type == ContentType.chapter) {
      return await DatabaseHelper().getChapters(parentId);
    } else {
      final sections = await DatabaseHelper().getSections(parentId);
      final hasDirect = await DatabaseHelper().hasDirectArticlesWithoutSection(parentId);
      if (hasDirect) {
        return [
          Section(
            id: -1,
            title: "Dispositions générales du chapitre",
            chapterId: parentId,
          ),
          ...sections,
        ];
      }
      return sections;
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
          final bottomPadding = MediaQuery.paddingOf(context).bottom;
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 40 + bottomPadding),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              String itemTitle = '';
              int itemId = 0;
              String? startArt;
              String? endArt;

              if (item is TitleStruct) {
                itemTitle = item.title;
                itemId = item.id!;
                startArt = item.startArticle;
                endArt = item.endArticle;
              } else if (item is Chapter) {
                itemTitle = item.title;
                itemId = item.id!;
                startArt = item.startArticle;
                endArt = item.endArticle;
              } else if (item is Section) {
                itemTitle = item.title;
                itemId = item.id ?? 0;
                startArt = item.startArticle;
                endArt = item.endArticle;
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
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemTitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (startArt != null && endArt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "(Articles $startArt à $endArt)",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                    ],
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
                      if (chapters.length == 1 &&
                          chapters.first.title.toLowerCase().contains("unique")) {
                        final hasSec = await DatabaseHelper().hasSections(chapters.first.id!);
                        if (!context.mounted) return;
                        if (hasSec) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContentScreen(
                                title: itemTitle,
                                type: ContentType.section,
                                parentId: chapters.first.id!,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleListScreen(
                                chapterTitle: itemTitle,
                                chapterId: chapters.first.id!,
                              ),
                            ),
                          );
                        }
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
                    } else if (type == ContentType.chapter) {
                      final hasSec = await DatabaseHelper().hasSections(itemId);
                      if (!context.mounted) return;
                      if (hasSec) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              title: itemTitle,
                              type: ContentType.section,
                              parentId: itemId,
                            ),
                          ),
                        );
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
                    } else {
                      // ContentType.section
                      if (itemId == -1) {
                        // Direct articles of chapter
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleListScreen(
                              chapterTitle: "$title - Dispositions générales",
                              chapterId: parentId,
                              sectionId: null,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleListScreen(
                              chapterTitle: itemTitle,
                              chapterId: parentId,
                              sectionId: itemId,
                            ),
                          ),
                        );
                      }
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
