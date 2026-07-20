import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_animate/flutter_animate.dart';
import '../models/law_modification_models.dart';
import '../widgets/code_num_app_bar.dart';
import 'law_modification_detail_screen.dart';

class LawModificationsScreen extends StatefulWidget {
  const LawModificationsScreen({super.key});

  @override
  State<LawModificationsScreen> createState() => _LawModificationsScreenState();
}

class _LawModificationsScreenState extends State<LawModificationsScreen> {
  late Future<List<LawModification>> _modificationsFuture;

  @override
  void initState() {
    super.initState();
    _modificationsFuture = _loadModifications();
  }

  Future<List<LawModification>> _loadModifications() async {
    try {
      final jsonString = await rootBundle.loadString('assets/modifications_lois.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => LawModification.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error loading modifications: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CodeNumAppBar(
        title: 'Modifications de lois',
      ),
      body: FutureBuilder<List<LawModification>>(
        future: _modificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur lors du chargement des modifications de lois.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucune modification enregistrée.'),
            );
          }

          final modifications = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: modifications.length,
            itemBuilder: (context, index) {
              final modification = modifications[index];
              return _buildLawCard(context, modification, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildLawCard(BuildContext context, LawModification modification, int index) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LawModificationDetailScreen(modification: modification),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.gavel_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          modification.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          modification.subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const Divider(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildDateBadge(
                    context,
                    label: 'Adoption',
                    date: modification.dateAdoption,
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  _buildDateBadge(
                    context,
                    label: 'Promulgation',
                    date: modification.datePromulgation,
                    icon: Icons.publish_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (100 * index).ms)
        .slideY(begin: 0.2, curve: Curves.easeOutQuad);
  }

  Widget _buildDateBadge(
    BuildContext context, {
    required String label,
    required String date,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            '$label : ',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          Text(
            date,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
