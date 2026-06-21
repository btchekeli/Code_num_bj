import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/code_models.dart';
import '../widgets/article_card.dart';
import '../widgets/code_num_app_bar.dart';
import 'article_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CodeNumAppBar(title: 'Favoris'),
      body: FutureBuilder<List<Article>>(
        future: DatabaseHelper().getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun favori'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return ArticleCard(
                article: articles[index],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailScreen(
                        articles: articles,
                        initialIndex: index,
                      ),
                    ),
                  );
                  // Refresh favorites when returning
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}
