import 'package:flutter/material.dart';
import '../screens/favorites_screen.dart';
import '../screens/all_titles_screen.dart';
import '../screens/all_articles_screen.dart';
import '../screens/about_screen.dart';

class CodeNumDrawer extends StatelessWidget {
  const CodeNumDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 75,
                      child:
                          Image.asset("assets/images/Icone_code_num_bj.png")),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.balance,
                        size: 30,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Code du numérique en\n République du Bénin',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                left: 10,
              ),
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Favoris'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavoritesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Tous les titres'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllTitlesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('Tous les articles'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllArticlesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 45.0, left: 10),
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('À propos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
