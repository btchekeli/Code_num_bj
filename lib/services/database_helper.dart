import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/code_models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'code_numerique.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE titles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        book_id INTEGER,
        FOREIGN KEY(book_id) REFERENCES books(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE chapters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        title_id INTEGER,
        FOREIGN KEY(title_id) REFERENCES titles(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE sections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        chapter_id INTEGER,
        FOREIGN KEY(chapter_id) REFERENCES chapters(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE articles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero TEXT,
        titre TEXT,
        texte TEXT,
        chapter_id INTEGER,
        section_id INTEGER,
        FOREIGN KEY(chapter_id) REFERENCES chapters(id),
        FOREIGN KEY(section_id) REFERENCES sections(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        article_id INTEGER,
        FOREIGN KEY(article_id) REFERENCES articles(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Re-create all tables to support sections and new JSON structure
      await db.execute('DROP TABLE IF EXISTS favorites');
      await db.execute('DROP TABLE IF EXISTS articles');
      await db.execute('DROP TABLE IF EXISTS sections');
      await db.execute('DROP TABLE IF EXISTS chapters');
      await db.execute('DROP TABLE IF EXISTS titles');
      await db.execute('DROP TABLE IF EXISTS books');

      await _createTables(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> reloadData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('favorites');
      await txn.delete('articles');
      await txn.delete('sections');
      await txn.delete('chapters');
      await txn.delete('titles');
      await txn.delete('books');
    });
    await _loadFromJson();
  }

  Future<void> initializeData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM books'),
    );

    if (count == 0) {
      await _loadFromJson();
    }
  }

  Future<void> _loadFromJson() async {
    try {
      String jsonString = await rootBundle.loadString('assets/code_numerique.json');
      Map<String, dynamic> data = json.decode(jsonString);
      final db = await database;

      await db.transaction((txn) async {
        for (var bookKey in data.keys) {
          int bookId = await txn.insert('books', {'title': bookKey});
          var bookVal = data[bookKey];
          if (bookVal is! Map) continue;

          // Direct articles on book?
          if (bookVal.containsKey('articles')) {
            int tId = await txn.insert('titles', {'title': 'Titre Unique', 'book_id': bookId});
            int cId = await txn.insert('chapters', {'title': 'Chapitre Unique', 'title_id': tId});
            for (var art in bookVal['articles']) {
              await txn.insert('articles', {
                'numero': art['numero'],
                'titre': art['titre'],
                'texte': art['texte'],
                'chapter_id': cId,
                'section_id': null,
              });
            }
          }

          // Process titles / chapters inside book
          for (var tKey in bookVal.keys) {
            if (tKey == 'articles') continue;
            var tVal = bookVal[tKey];

            if (tKey.toString().startsWith('CHAPITRE')) {
              int tId = await txn.insert('titles', {'title': 'Titre Unique', 'book_id': bookId});
              int cId = await txn.insert('chapters', {'title': tKey, 'title_id': tId});
              await _processChapterNode(txn, tVal, cId);
            } else {
              int tId = await txn.insert('titles', {'title': tKey, 'book_id': bookId});
              if (tVal is Map) {
                if (tVal.containsKey('articles')) {
                  int cId = await txn.insert('chapters', {'title': 'Chapitre Unique', 'title_id': tId});
                  for (var art in tVal['articles']) {
                    await txn.insert('articles', {
                      'numero': art['numero'],
                      'titre': art['titre'],
                      'texte': art['texte'],
                      'chapter_id': cId,
                      'section_id': null,
                    });
                  }
                }
                for (var cKey in tVal.keys) {
                  if (cKey == 'articles') continue;
                  var cVal = tVal[cKey];
                  int cId = await txn.insert('chapters', {'title': cKey, 'title_id': tId});
                  await _processChapterNode(txn, cVal, cId);
                }
              }
            }
          }
        }
      });
      debugPrint("Data loaded into database successfully.");
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  Future<void> _processChapterNode(Transaction txn, dynamic cVal, int chapterId) async {
    if (cVal is! Map) return;

    // Direct articles in chapter
    if (cVal.containsKey('articles')) {
      for (var art in cVal['articles']) {
        await txn.insert('articles', {
          'numero': art['numero'],
          'titre': art['titre'],
          'texte': art['texte'],
          'chapter_id': chapterId,
          'section_id': null,
        });
      }
    }

    // Sections inside chapter
    for (var sKey in cVal.keys) {
      if (sKey == 'articles') continue;
      var sVal = cVal[sKey];
      if (sVal is! Map) continue;

      if (sVal.containsKey('articles')) {
        int sId = await txn.insert('sections', {'title': sKey, 'chapter_id': chapterId});
        for (var art in sVal['articles']) {
          await txn.insert('articles', {
            'numero': art['numero'],
            'titre': art['titre'],
            'texte': art['texte'],
            'chapter_id': chapterId,
            'section_id': sId,
          });
        }
      }

      // Check for sub-sections or nested sections
      for (var subKey in sVal.keys) {
        if (subKey == 'articles') continue;
        var subVal = sVal[subKey];
        if (subVal is Map && subVal.containsKey('articles')) {
          String combinedTitle = subKey.toString().startsWith("SECTION")
              ? subKey
              : "$sKey - $subKey";
          int sId = await txn.insert('sections', {'title': combinedTitle, 'chapter_id': chapterId});
          for (var art in subVal['articles']) {
            await txn.insert('articles', {
              'numero': art['numero'],
              'titre': art['titre'],
              'texte': art['texte'],
              'chapter_id': chapterId,
              'section_id': sId,
            });
          }
        }
      }
    }
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<List<TitleStruct>> getTitles(int bookId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'titles',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    return List.generate(maps.length, (i) {
      return TitleStruct.fromMap(maps[i]);
    });
  }

  Future<List<TitleStruct>> getAllTitles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, b.title as book_title,
      (SELECT a.numero FROM articles a JOIN chapters c ON c.id = a.chapter_id WHERE c.title_id = t.id ORDER BY a.id ASC LIMIT 1) as start_article,
      (SELECT a.numero FROM articles a JOIN chapters c ON c.id = a.chapter_id WHERE c.title_id = t.id ORDER BY a.id DESC LIMIT 1) as end_article
      FROM titles t
      JOIN books b ON b.id = t.book_id
      ORDER BY t.id ASC
    ''');
    return List.generate(maps.length, (i) {
      return TitleStruct.fromMap(maps[i]);
    });
  }

  Future<List<Chapter>> getChapters(int titleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.*,
      (SELECT a.numero FROM articles a WHERE a.chapter_id = c.id ORDER BY a.id ASC LIMIT 1) as start_article,
      (SELECT a.numero FROM articles a WHERE a.chapter_id = c.id ORDER BY a.id DESC LIMIT 1) as end_article
      FROM chapters c
      WHERE c.title_id = ?
      ORDER BY c.id ASC
    ''', [titleId]);
    return List.generate(maps.length, (i) {
      return Chapter.fromMap(maps[i]);
    });
  }

  Future<List<Section>> getSections(int chapterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.*,
      (SELECT a.numero FROM articles a WHERE a.section_id = s.id ORDER BY a.id ASC LIMIT 1) as start_article,
      (SELECT a.numero FROM articles a WHERE a.section_id = s.id ORDER BY a.id DESC LIMIT 1) as end_article
      FROM sections s
      WHERE s.chapter_id = ?
      ORDER BY s.id ASC
    ''', [chapterId]);
    return List.generate(maps.length, (i) {
      return Section.fromMap(maps[i]);
    });
  }

  Future<bool> hasSections(int chapterId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sections WHERE chapter_id = ?', [chapterId]),
    );
    return (count ?? 0) > 0;
  }

  Future<bool> hasDirectArticlesWithoutSection(int chapterId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM articles WHERE chapter_id = ? AND section_id IS NULL', [chapterId]),
    );
    return (count ?? 0) > 0;
  }

  Future<List<Article>> getArticles(int chapterId, {int? sectionId}) async {
    final db = await database;
    String sql = '''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title, s.title as section_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      LEFT JOIN sections s ON a.section_id = s.id
      WHERE a.chapter_id = ?
    ''';
    List<dynamic> args = [chapterId];
    if (sectionId != null) {
      sql += ' AND a.section_id = ?';
      args.add(sectionId);
    }
    sql += ' ORDER BY a.id ASC';
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<List<Article>> getDirectChapterArticles(int chapterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title, s.title as section_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      LEFT JOIN sections s ON a.section_id = s.id
      WHERE a.chapter_id = ? AND a.section_id IS NULL
      ORDER BY a.id ASC
    ''', [chapterId]);
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<List<Article>> getArticlesBySection(int sectionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title, s.title as section_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      LEFT JOIN sections s ON a.section_id = s.id
      WHERE a.section_id = ?
      ORDER BY a.id ASC
    ''', [sectionId]);
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<List<Article>> getAllArticles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title, s.title as section_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      LEFT JOIN sections s ON a.section_id = s.id
      ORDER BY b.id, t.id, c.id, a.id
    ''');
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<List<Article>> searchArticles(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title, s.title as section_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      LEFT JOIN sections s ON a.section_id = s.id
      WHERE a.texte LIKE ? OR a.numero LIKE ? OR a.titre LIKE ?
      ORDER BY a.id ASC
    ''', ['%$query%', '%$query%', '%$query%']);
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<Article?> getArticleWithHierarchy(int articleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title, s.title as section_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      LEFT JOIN sections s ON a.section_id = s.id
      WHERE a.id = ?
    ''', [articleId]);

    if (maps.isNotEmpty) {
      return Article.fromMap(maps.first);
    }
    return null;
  }

  Future<void> toggleFavorite(int articleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );

    if (maps.isEmpty) {
      await db.insert('favorites', {'article_id': articleId});
    } else {
      await db.delete(
        'favorites',
        where: 'article_id = ?',
        whereArgs: [articleId],
      );
    }
  }

  Future<bool> isFavorite(int articleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
    return maps.isNotEmpty;
  }

  Future<List<Article>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title, s.title as section_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      LEFT JOIN sections s ON a.section_id = s.id
      INNER JOIN favorites f ON a.id = f.article_id
      ORDER BY f.id DESC
    ''');
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }
}
