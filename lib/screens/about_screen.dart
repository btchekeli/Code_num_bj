import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24.0,
          24.0,
          24.0,
          40 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.balance_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  Text(
                    'Code du numérique en République du Bénin',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildSectionTitle(context, 'Version Légale'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              "Loi n° 2017-20 portant code du numérique en République du Bénin. \n \nL’Assemblée nationale a délibéré et adopté en sa séance du mardi 13 juin 2017, la loi dont la teneur a été reproduite dans cette application",
            ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Développement'),
            const SizedBox(height: 12),
            _buildContributorCard(
              context,
              icon: Icons.code_rounded,
              title: 'Développé par :',
              contributors: [
                'Brunel TCHEKELI',
              ],
              extra: 'Site web : https://btchekeli.github.io/',
            ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),
            const SizedBox(height: 24),
            _buildContributorCard(
              context,
              icon: Icons.edit_note_rounded,
              title: 'Assistances, corrections et relectures :',
              contributors: [
                'Christella W. DEKADJEVI',
                'Ozias Jawu AHOUSSINOU',
              ],
            ).animate().fadeIn(delay: 900.ms).slideX(begin: 0.1),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Développé avec amour',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String content,
      {IconData? icon}) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributorCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> contributors,
    String? extra,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...contributors.map(
                    (name) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildLinkedInBadge(),
                        ],
                      ),
                    ),
                  ),
                  if (extra != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      extra,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedInBadge() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2), // Bleu officiel LinkedIn
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: const Text(
        'in',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          fontFamily: 'sans-serif',
          height: 1.0,
        ),
      ),
    );
  }
}
