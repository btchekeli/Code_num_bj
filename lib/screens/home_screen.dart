import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/database_helper.dart';
import '../models/code_models.dart';
import 'content_screen.dart';
import 'article_list_screen.dart';
import '../widgets/code_num_app_bar.dart';
import '../widgets/code_num_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CodeNumAppBar(
        title: 'Code du numérique',
      ),
      drawer: const CodeNumDrawer(),
      body: FutureBuilder<List<Book>>(
        future: DatabaseHelper().getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books found'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 30,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final titles = await DatabaseHelper().getTitles(book.id!);
                    if (!context.mounted) return;
                    if (titles.length == 1 && titles.first.title.toLowerCase().contains("unique")) {
                      final chapters = await DatabaseHelper().getChapters(titles.first.id!);
                      if (!context.mounted) return;
                      if (chapters.length == 1 && chapters.first.title.toLowerCase().contains("unique")) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleListScreen(
                              chapterTitle: book.title,
                              chapterId: chapters.first.id!,
                            ),
                          ),
                        );
                        return;
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentScreen(
                              title: book.title,
                              type: ContentType.chapter,
                              parentId: titles.first.id!,
                            ),
                          ),
                        );
                        return;
                      }
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContentScreen(
                          title: book.title,
                          type: ContentType.title,
                          parentId: book.id!,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            book.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (50 * (index > 15 ? 15 : index)).ms).slideX();
            },
          );
        },
      ),
    );
  }
}
