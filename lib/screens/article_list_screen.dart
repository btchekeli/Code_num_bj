import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/code_models.dart';
import '../widgets/code_num_app_bar.dart';
import '../widgets/article_card.dart';
import 'article_detail_screen.dart';

class ArticleListScreen extends StatelessWidget {
  final String chapterTitle;
  final int chapterId;

  const ArticleListScreen({
    super.key,
    required this.chapterTitle,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CodeNumAppBar(title: chapterTitle),
      body: FutureBuilder<List<Article>>(
        future: DatabaseHelper().getArticles(chapterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun article trouvé'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return ArticleCard(
                article: articles[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailScreen(
                        articles: articles,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
