class Article {
  final int? id;
  final String numero;
  final String? titre;
  final String texte;
  final int chapterId;
  final int? sectionId;
  final String? bookTitle;
  final String? titleTitle;
  final String? chapterTitle;
  final String? sectionTitle;

  Article({
    this.id,
    required this.numero,
    this.titre,
    required this.texte,
    required this.chapterId,
    this.sectionId,
    this.bookTitle,
    this.titleTitle,
    this.chapterTitle,
    this.sectionTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'titre': titre,
      'texte': texte,
      'chapter_id': chapterId,
      'section_id': sectionId,
      'book_title': bookTitle,
      'title_title': titleTitle,
      'chapter_title': chapterTitle,
      'section_title': sectionTitle,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      numero: map['numero'],
      titre: map['titre'],
      texte: map['texte'],
      chapterId: map['chapter_id'],
      sectionId: map['section_id'],
      bookTitle: map['book_title'],
      titleTitle: map['title_title'],
      chapterTitle: map['chapter_title'],
      sectionTitle: map['section_title'],
    );
  }
}

class Section {
  final int? id;
  final String title;
  final int chapterId;
  final String? startArticle;
  final String? endArticle;
  final List<Article> articles;

  Section({
    this.id,
    required this.title,
    required this.chapterId,
    this.startArticle,
    this.endArticle,
    this.articles = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'chapter_id': chapterId,
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'],
      title: map['title'],
      chapterId: map['chapter_id'],
      startArticle: map['start_article'],
      endArticle: map['end_article'],
    );
  }
}

class Chapter {
  final int? id;
  final String title;
  final int titleId;
  final String? startArticle;
  final String? endArticle;
  final List<Section> sections;
  final List<Article> articles;

  Chapter({
    this.id,
    required this.title,
    required this.titleId,
    this.startArticle,
    this.endArticle,
    this.sections = const [],
    this.articles = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'title_id': titleId,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      title: map['title'],
      titleId: map['title_id'],
      startArticle: map['start_article'],
      endArticle: map['end_article'],
    );
  }
}

class TitleStruct {
  final int? id;
  final String title;
  final int bookId;
  final String? bookTitle;
  final String? startArticle;
  final String? endArticle;
  final List<Chapter> chapters;

  TitleStruct({
    this.id,
    required this.title,
    required this.bookId,
    this.bookTitle,
    this.startArticle,
    this.endArticle,
    this.chapters = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'book_id': bookId,
      'book_title': bookTitle,
      'start_article': startArticle,
      'end_article': endArticle,
    };
  }

  factory TitleStruct.fromMap(Map<String, dynamic> map) {
    return TitleStruct(
      id: map['id'],
      title: map['title'],
      bookId: map['book_id'],
      bookTitle: map['book_title'],
      startArticle: map['start_article'],
      endArticle: map['end_article'],
    );
  }
}

class Book {
  final int? id;
  final String title;
  final String? startArticle;
  final String? endArticle;
  final List<TitleStruct> titles;

  Book({
    this.id,
    required this.title,
    this.startArticle,
    this.endArticle,
    this.titles = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_article': startArticle,
      'end_article': endArticle,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      startArticle: map['start_article'],
      endArticle: map['end_article'],
    );
  }
}

String formatArticlesRange(String? startArticle, String? endArticle) {
  if (startArticle == null || endArticle == null) return '';
  final startTrimmed = startArticle.trim();
  final endTrimmed = endArticle.trim();
  if (startTrimmed.isEmpty || endTrimmed.isEmpty) return '';

  final cleanStart = startTrimmed.replaceFirst(RegExp(r'^articles?\s*', caseSensitive: false), '').trim();
  final cleanEnd = endTrimmed.replaceFirst(RegExp(r'^articles?\s*', caseSensitive: false), '').trim();

  if (cleanStart.toLowerCase() == cleanEnd.toLowerCase()) {
    return '(Article $cleanStart)';
  }
  return '(Articles $cleanStart à $cleanEnd)';
}
