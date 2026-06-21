import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/code_models.dart';
import '../services/database_helper.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final String? highlightedQuery;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.highlightedQuery,
    this.onTap,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final isFav = await DatabaseHelper().isFavorite(widget.article.id!);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    await DatabaseHelper().toggleFavorite(widget.article.id!);
    await _checkFavorite();
  }

  List<InlineSpan> _getHighlightedSpans(
    String text,
    String query,
    BuildContext context, {
    TextStyle? style,
  }) {
    if (query.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: style));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + lowerQuery.length),
          style: style?.copyWith(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ) ??
              TextStyle(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
        ),
      );

      start = index + lowerQuery.length;
    }
    return spans;
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    BuildContext context, {
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: TextAlign.justify,
      );
    }

    return Text.rich(
      TextSpan(children: _getHighlightedSpans(text, query, context, style: style)),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: TextAlign.justify,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          ..._getHighlightedSpans(
                            widget.article.numero,
                            widget.highlightedQuery ?? '',
                            context,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                          ),
                          if (widget.article.titre != null && widget.article.titre!.isNotEmpty)
                            ..._getHighlightedSpans(
                              ' : ${widget.article.titre}',
                              widget.highlightedQuery ?? '',
                              context,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.normal,
                                    height: 1.4,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : null,
                          size: 22,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          final textToCopy = widget.article.titre != null &&
                                  widget.article.titre!.isNotEmpty
                              ? "${widget.article.numero} : ${widget.article.titre}\n\n${widget.article.texte}"
                              : "${widget.article.numero}\n\n${widget.article.texte}";
                          Clipboard.setData(ClipboardData(text: textToCopy));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Article copié')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHighlightedText(
                widget.article.texte,
                widget.highlightedQuery ?? '',
                context,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
