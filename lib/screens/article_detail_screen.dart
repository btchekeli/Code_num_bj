import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/code_models.dart';
import '../services/database_helper.dart';
import '../widgets/code_num_app_bar.dart';

class ArticleDetailScreen extends StatefulWidget {
  final List<Article> articles;
  final int initialIndex;

  const ArticleDetailScreen({
    super.key,
    required this.articles,
    required this.initialIndex,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatText(String text) {
    if (text.isEmpty) return text;
    final lower = text.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CodeNumAppBar(
        title: widget.articles[_currentIndex].numero,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.articles.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final article = widget.articles[index];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hierarchy Breadcrumbs
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBreadcrumbItem(context, '', article.bookTitle),
                      _buildBreadcrumbItem(context, '', article.titleTitle),
                      _buildBreadcrumbItem(context, '', article.chapterTitle,
                          isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Article Header
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: article.numero,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      if (article.titre != null && article.titre!.isNotEmpty)
                        TextSpan(
                          text: ' : ${article.titre}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Article Text
                Text(
                  article.texte,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 100), // Space for bottom actions
              ],
            ),
          );
        },
      ),
      bottomNavigationBar:
          _buildBottomActions(context, widget.articles[_currentIndex]),
    );
  }

  Widget _buildBreadcrumbItem(BuildContext context, String label, String? value,
      {bool isLast = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
          //const SizedBox(height: 2),
          Text(
            _formatText(value),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Article article) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              icon: Icons.navigate_before_rounded,
              label: 'Précédent',
              onTap: _currentIndex > 0
                  ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
              color:
                  _currentIndex > 0 ? null : Colors.grey.withValues(alpha: 0.5),
            ),
            _buildActionButton(
              context,
              icon: Icons.share_rounded,
              label: 'Partager',
              onTap: () async {
                try {
                  final textToShare = article.titre != null &&
                          article.titre!.isNotEmpty
                      ? "${article.numero} : ${article.titre}\n\n${article.texte}"
                      : "${article.numero}\n\n${article.texte}";
                  await SharePlus.instance.share(
                    ShareParams(text: textToShare),
                  );
                } catch (e) {
                  debugPrint("Error sharing: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Impossible de partager sur cet appareil')),
                    );
                  }
                }
              },
            ),
            _buildFavoriteButton(article),
            _buildActionButton(
              context,
              icon: Icons.copy_rounded,
              label: 'Copier',
              onTap: () {
                final textToCopy = article.titre != null &&
                        article.titre!.isNotEmpty
                    ? "${article.numero} : ${article.titre}\n\n${article.texte}"
                    : "${article.numero}\n\n${article.texte}";
                Clipboard.setData(ClipboardData(text: textToCopy));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Article copié dans le presse-papier')),
                );
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.navigate_next_rounded,
              label: 'Suivant',
              onTap: _currentIndex < widget.articles.length - 1
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
              color: _currentIndex < widget.articles.length - 1
                  ? null
                  : Colors.grey.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(Article article) {
    return _FavoriteWidget(
      article: article,
      buildActionButton: _buildActionButton,
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    final bool isDisabled = onTap == null;
    final Color buttonColor = color ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isDisabled ? Colors.grey.withValues(alpha: 0.5) : buttonColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDisabled
                    ? Colors.grey.withValues(alpha: 0.5)
                    : (color ?? Theme.of(context).colorScheme.onSurfaceVariant),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteWidget extends StatefulWidget {
  final Article article;
  final Widget Function(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) buildActionButton;

  const _FavoriteWidget({
    required this.article,
    required this.buildActionButton,
  });

  @override
  State<_FavoriteWidget> createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<_FavoriteWidget> {
  bool? _isFav;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  @override
  void didUpdateWidget(_FavoriteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.id != widget.article.id) {
      _loadFavorite();
    }
  }

  Future<void> _loadFavorite() async {
    final isFav = await DatabaseHelper().isFavorite(widget.article.id!);
    if (mounted) {
      setState(() {
        _isFav = isFav;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFav = _isFav ?? false;
    return widget.buildActionButton(
      context,
      icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      label: 'Favoris',
      color: isFav ? Colors.red : null,
      onTap: _isFav == null
          ? null
          : () async {
              setState(() {
                _isFav = !isFav;
              });
              await DatabaseHelper().toggleFavorite(widget.article.id!);
            },
    );
  }
}
