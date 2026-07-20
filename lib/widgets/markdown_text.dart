import 'package:flutter/material.dart';

class MarkdownText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const MarkdownText({
    super.key,
    required this.text,
    this.query = '',
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  static List<InlineSpan> getHighlightedSpans(
    String text,
    String query,
    BuildContext context, {
    TextStyle? style,
  }) {
    if (query.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }

    final List<InlineSpan> spans = [];
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

  List<InlineSpan> _parseMarkdown(BuildContext context) {
    final List<InlineSpan> spans = [];
    final List<String> parts = text.split('**');

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;
      final bool isBold = i % 2 == 1;
      final TextStyle currentStyle = isBold
          ? (style?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontWeight: FontWeight.bold))
          : (style ?? const TextStyle());

      if (query.isNotEmpty) {
        spans.addAll(getHighlightedSpans(part, query, context, style: currentStyle));
      } else {
        spans.add(TextSpan(text: part, style: currentStyle));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: _parseMarkdown(context)),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign ?? TextAlign.justify,
    );
  }
}
