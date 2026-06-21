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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE favorites(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          article_id INTEGER,
          FOREIGN KEY(article_id) REFERENCES articles(id)
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
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
      CREATE TABLE articles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero TEXT,
        titre TEXT,
        texte TEXT,
        chapter_id INTEGER,
        FOREIGN KEY(chapter_id) REFERENCES chapters(id)
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
          await _processNode(txn, data[bookKey], bookId, null, null, bookKey);
        }
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
  }

  Future<void> _processNode(
    Transaction txn,
    dynamic node,
    int bookId,
    int? currentTitleId,
    int? currentChapterId,
    String nodeName,
  ) async {
    if (node is Map) {
      if (node.containsKey('articles')) {
        int tId = currentTitleId ??
            await txn.insert('titles', {'title': 'Titre Unique', 'book_id': bookId});
        int cId = currentChapterId ??
            await txn.insert('chapters', {
              'title': nodeName.startsWith('SECTION') ? nodeName : 'Chapitre Unique',
              'title_id': tId
            });

        List<dynamic> articlesList = node['articles'];
        for (var articleData in articlesList) {
          await txn.insert('articles', {
            'numero': articleData['numero'],
            'titre': articleData['titre'],
            'texte': articleData['texte'],
            'chapter_id': cId,
          });
        }
      }

      for (var key in node.keys) {
        if (key != 'articles') {
          int? newTitleId = currentTitleId;
          int? newChapterId = currentChapterId;

          if (currentTitleId == null) {
            newTitleId = await txn.insert('titles', {'title': key, 'book_id': bookId});
          } else if (currentChapterId == null) {
            newChapterId = await txn.insert('chapters', {'title': key, 'title_id': newTitleId});
          } else {
            // Treat sections or deeper levels as chapters under the same title
            newChapterId = await txn.insert('chapters', {'title': key, 'title_id': newTitleId});
          }

          await _processNode(txn, node[key], bookId, newTitleId, newChapterId, key as String);
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
    ''');
    return List.generate(maps.length, (i) {
      return TitleStruct.fromMap(maps[i]);
    });
  }

  Future<List<Chapter>> getChapters(int titleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chapters',
      where: 'title_id = ?',
      whereArgs: [titleId],
    );
    return List.generate(maps.length, (i) {
      return Chapter.fromMap(maps[i]);
    });
  }

  Future<List<Article>> getArticles(int chapterId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      WHERE a.chapter_id = ?
    ''', [chapterId]);
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<List<Article>> getAllArticles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      ORDER BY b.id, t.id, c.id, a.id
    ''');
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<List<Article>> searchArticles(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
      WHERE a.texte LIKE ? OR a.numero LIKE ? OR a.titre LIKE ?
    ''', ['%$query%', '%$query%', '%$query%']);
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }

  Future<Article?> getArticleWithHierarchy(int articleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT a.*, c.title as chapter_title, t.title as title_title, b.title as book_title
      FROM articles a
      JOIN chapters c ON a.chapter_id = c.id
      JOIN titles t ON c.title_id = t.id
      JOIN books b ON t.book_id = b.id
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
      SELECT a.* FROM articles a
      INNER JOIN favorites f ON a.id = f.article_id
    ''');
    return List.generate(maps.length, (i) {
      return Article.fromMap(maps[i]);
    });
  }
}
