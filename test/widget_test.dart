import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:code_numerique_app/models/code_models.dart';
import 'package:code_numerique_app/services/settings_service.dart';

void main() {
  group('Code Models Tests', () {
    test('Article fromMap and toMap serialization', () {
      final article = Article(
        id: 1,
        numero: 'Article 1er',
        titre: 'Champ d\'application',
        texte: 'Le présent code régit...',
        chapterId: 10,
        bookTitle: 'Livre I',
        titleTitle: 'Titre I',
        chapterTitle: 'Chapitre I',
      );

      final map = article.toMap();
      expect(map['numero'], 'Article 1er');
      expect(map['chapter_id'], 10);

      final fromMap = Article.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.numero, 'Article 1er');
      expect(fromMap.titre, 'Champ d\'application');
      expect(fromMap.texte, 'Le présent code régit...');
      expect(fromMap.chapterId, 10);
      expect(fromMap.bookTitle, 'Livre I');
    });

    test('Book and TitleStruct models instantiation', () {
      final book = Book(id: 1, title: 'LIVRE PREMIER');
      expect(book.id, 1);
      expect(book.title, 'LIVRE PREMIER');
      expect(book.titles, isEmpty);

      final title = TitleStruct(
        id: 2,
        title: 'TITRE I',
        bookId: 1,
        startArticle: 'Article 1er',
        endArticle: 'Article 15',
      );
      expect(title.title, 'TITRE I');
      expect(title.bookId, 1);
    });
  });

  group('Settings Service Tests', () {
    test('SettingsService initializes with default values', () {
      final settings = SettingsService();
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.textScaleFactor, 1.0);
    });
  });
}
