import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/law_modification_models.dart';
import '../widgets/code_num_app_bar.dart';
import '../widgets/markdown_text.dart';

class LawModificationDetailScreen extends StatelessWidget {
  final LawModification modification;

  const LawModificationDetailScreen({
    super.key,
    required this.modification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CodeNumAppBar(
        title: modification.title,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata Header Card
            _buildHeaderCard(context),
            const SizedBox(height: 24),

            // Articles Section Title
            Text(
              'Articles de la loi modificative',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 12),

            // List of Modifying Articles
            ...modification.articles.asMap().entries.map((entry) {
              final index = entry.key;
              final article = entry.value;
              return _buildModifyingArticle(context, article, index);
            }),
            const SizedBox(height: 24),

            // Signatories Section
            _buildSignatoriesSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              modification.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              modification.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.event_note_rounded,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Adoptée le : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: modification.dateAdoption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Promulguée le : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: modification.datePromulgation),
                        const TextSpan(
                          text: ' par ',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: modification.promulgator,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildModifyingArticle(BuildContext context, ModifyingArticle article, int index) {
    final theme = Theme.of(context);
    final hasModifications = article.modifications != null && article.modifications!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.numero,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                if (article.description != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      article.description!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // If it modifies sub-articles
            if (hasModifications) ...[
              ...article.modifications!.map((mod) {
                return Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      '${mod.articleOriginal} nouveau',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    subtitle: Text(
                      mod.titre,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    childrenPadding: const EdgeInsets.all(16.0),
                    expandedAlignment: Alignment.topLeft,
                    children: [
                      MarkdownText(
                        text: mod.nouveauTexte,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else if (article.texte != null) ...[
              // If it is a simple text article
              MarkdownText(
                text: article.texte!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * (index + 2)).ms).slideY(begin: 0.15, curve: Curves.easeOutQuad);
  }

  Widget _buildSignatoriesSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_turned_in_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Signataires',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...modification.signatories.map((sig) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sig.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    sig.role,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: (100 * (modification.articles.length + 3)).ms);
  }
}
