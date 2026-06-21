import 'dart:async';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/code_models.dart';
import '../widgets/code_num_app_bar.dart';
import '../widgets/article_card.dart';
import 'article_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Article> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _results = [];
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final results = await DatabaseHelper().searchArticles(query);
      if (!mounted) return;
      setState(() {
        _results = results;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de recherche: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CodeNumAppBar(
        title: 'Recherche',
        showSearch: false,
        titleWidget: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Rechercher un article...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty && _controller.text.isNotEmpty
              ? const Center(child: Text('Aucun résultat'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final article = _results[index];
                    return ArticleCard(
                      article: article,
                      highlightedQuery: _controller.text,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailScreen(
                              articles: _results,
                              initialIndex: index,
                            ),
                          ),
                        );
                        // Refresh state in case favorites were toggled
                        setState(() {});
                      },
                    );
                  },
                ),
    );
  }
}
