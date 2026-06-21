// lib/services/db_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DbService {
  static Database? _db;

  static Future<Database> initDb() async {
    if (_db != null) {
      return _db!;
    }

    final path = await getDatabasesPath();
    _db = await openDatabase(
      join(path, 'code_numerique.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE articles(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            livre_id INTEGER,
            livre TEXT,
            titre TEXT,
            chapitre TEXT,
            section TEXT,
            paragraphe TEXT,
            numero TEXT,
            texte TEXT
          )
        ''');
      },
      version: 1,
    );
    await _importerJsonDansSQLite(_db!);
    return _db!;
  }

  static Future<void> _importerJsonDansSQLite(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM articles'),
    );
    if (count != 0) {
      debugPrint("✅ Les données existent déjà, import ignoré");
      return;
    }

    final Map<String, int> ordreDesLivres = {
      "Livre Premier : Des personnes": 1,
      "Livre Deuxieme : La famille": 2,
      "Livre Troisieme : Des successions - des donations entre vifs et des testaments":
          3,
      "Livre Quatrieme : Application du code dans l'espace et dans le temps et dispositions transitoires":
          4,
    };

    final jsonString = await rootBundle.loadString('assets/code_numerique.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);

    for (var livre in data.keys) {
      final int livreId = ordreDesLivres[livre] ?? 99;
      final titres = data[livre];
      for (var titre in titres.keys) {
        final chapitres = titres[titre];
        for (var chapitre in chapitres.keys) {
          final contenuChapitre = chapitres[chapitre];
          for (var cle in contenuChapitre.keys) {
            if (cle == "articles") {
              for (var article in contenuChapitre[cle]) {
                await db.insert('articles', {
                  'livre_id': livreId,
                  'livre': livre,
                  'titre': titre,
                  'chapitre': chapitre,
                  'section': null,
                  'paragraphe': null,
                  'numero': article['numero'],
                  'texte': article['texte'],
                });
              }
            } else {
              final section = cle;
              final contenuSection = contenuChapitre[cle];
              for (var cle2 in contenuSection.keys) {
                if (cle2 == "articles") {
                  for (var article in contenuSection[cle2]) {
                    await db.insert('articles', {
                      'livre_id': livreId,
                      'livre': livre,
                      'titre': titre,
                      'chapitre': chapitre,
                      'section': section,
                      'paragraphe': null,
                      'numero': article['numero'],
                      'texte': article['texte'],
                    });
                  }
                } else {
                  final paragraphe = cle2;
                  final articles = contenuSection[cle2];
                  for (var article in articles) {
                    await db.insert('articles', {
                      'livre_id': livreId,
                      'livre': livre,
                      'titre': titre,
                      'chapitre': chapitre,
                      'section': section,
                      'paragraphe': paragraphe,
                      'numero': article['numero'],
                      'texte': article['texte'],
                    });
                  }
                }
              }
            }
          }
        }
      }
    }
    debugPrint("✅ Import JSON → SQLite terminé !");
  }

  static Future<List<Map<String, dynamic>>> searchArticles(String query) async {
    final db = _db;
    if (db == null) {
      return [];
    }
    final List<Map<String, dynamic>> results = await db.query(
      'articles',
      where: 'texte LIKE ? OR numero LIKE ? OR titre LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'id',
    );
    return results;
  }
}
