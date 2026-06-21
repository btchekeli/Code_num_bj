import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../screens/search_screen.dart';

class CodeNumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final bool showSearch;

  const CodeNumAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return AppBar(
      title: titleWidget ??
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          ),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      elevation: 5,
      shadowColor: Colors.grey,
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Rechercher',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        IconButton(
          icon: const Icon(Icons.text_fields),
          tooltip: 'Taille du texte',
          onPressed: () => _showTextSizeDialog(context, settings),
        ),
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: child.key == const ValueKey('dark')
                  ? Tween<double>(begin: 0.5, end: 1).animate(anim)
                  : Tween<double>(begin: 0.75, end: 1).animate(anim),
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: settings.themeMode == ThemeMode.dark
                ? const Icon(Icons.light_mode, key: ValueKey('light'))
                : const Icon(Icons.invert_colors, key: ValueKey('dark')),
          ),
          tooltip: 'Changer de thème',
          onPressed: () {
            settings.toggleTheme();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showTextSizeDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taille du texte'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields, size: 20),
                    Expanded(
                      child: Slider(
                        value: settings.textScaleFactor,
                        min: 0.8,
                        max: 1.0,
                        divisions: 6,
                        label: '${(settings.textScaleFactor * 100).round()}%',
                        onChanged: (value) {
                          settings.updateTextScale(value);
                          setState(() {});
                        },
                      ),
                    ),
                    const Icon(Icons.text_fields, size: 30),
                  ],
                ),
                Text(
                  'Aperçu du texte',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
