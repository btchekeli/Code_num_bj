import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/database_helper.dart';
import '../models/code_models.dart';
import '../widgets/code_num_app_bar.dart';
import 'article_detail_screen.dart';

class AllArticlesScreen extends StatelessWidget {
  const AllArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CodeNumAppBar(title: 'Tous les Articles'),
      body: FutureBuilder<List<Article>>(
        future: DatabaseHelper().getAllArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun article trouvé'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return _buildModernArticleCard(context, article, index, articles);
            },
          );
        },
      ),
    );
  }

  Widget _buildModernArticleCard(BuildContext context, Article article,
      int index, List<Article> allArticles) {
    final String previewText = article.texte.length > 100
        ? "${article.texte.substring(0, 100)}..."
        : article.texte;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailScreen(
                articles: allArticles,
                initialIndex: index,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      article.numero,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                previewText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatText(
                          "${article.bookTitle} > ${article.titleTitle}"),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (40 * (index > 15 ? 15 : index)).ms).slideY(begin: 0.1);
  }

  String _formatText(String text) {
    if (text.isEmpty) return text;
    final lower = text.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}
