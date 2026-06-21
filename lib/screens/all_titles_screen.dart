import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/database_helper.dart';
import '../models/code_models.dart';
import '../widgets/code_num_app_bar.dart';
import 'content_screen.dart';
import 'article_list_screen.dart';

class AllTitlesScreen extends StatelessWidget {
  const AllTitlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CodeNumAppBar(title: 'Tous les Titres'),
      body: FutureBuilder<List<TitleStruct>>(
        future: DatabaseHelper().getAllTitles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun titre trouvé'));
          }

          final titles = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: titles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = titles[index];
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
                        _formatText(item.bookTitle ?? ''),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatText(item.title.toLowerCase().contains('unique') ? (item.bookTitle ?? 'Titre Unique') : item.title),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (item.startArticle != null && item.endArticle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            _formatText(
                                "(Articles ${item.startArticle} à ${item.endArticle})"),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
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
                    final chapters = await DatabaseHelper().getChapters(item.id!);
                    if (!context.mounted) return;
                    if (chapters.length == 1 && chapters.first.title.toLowerCase().contains("unique")) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleListScreen(
                            chapterTitle: item.title.toLowerCase().contains('unique') ? (item.bookTitle ?? 'Articles') : item.title,
                            chapterId: chapters.first.id!,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentScreen(
                            title: item.title.toLowerCase().contains('unique') ? (item.bookTitle ?? 'Titre Unique') : item.title,
                            type: ContentType.chapter,
                            parentId: item.id!,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ).animate().fadeIn(delay: (20 * (index > 15 ? 15 : index)).ms).slideX(begin: 0.1);
            },
          );
        },
      ),
    );
  }

  String _formatText(String text) {
    if (text.isEmpty) return text;
    // Remove "Article " prefix if present in the range numbers? No, range is "(Articles X à Y)".
    // Just simple sentence case.
    final lower = text.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}
