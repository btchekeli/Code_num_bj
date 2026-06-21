class Article {
  final int? id;
  final String numero;
  final String? titre;
  final String texte;
  final int chapterId;
  final String? bookTitle;
  final String? titleTitle;
  final String? chapterTitle;

  Article({
    this.id,
    required this.numero,
    this.titre,
    required this.texte,
    required this.chapterId,
    this.bookTitle,
    this.titleTitle,
    this.chapterTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'titre': titre,
      'texte': texte,
      'chapter_id': chapterId,
      'book_title': bookTitle,
      'title_title': titleTitle,
      'chapter_title': chapterTitle,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      numero: map['numero'],
      titre: map['titre'],
      texte: map['texte'],
      chapterId: map['chapter_id'],
      bookTitle: map['book_title'],
      titleTitle: map['title_title'],
      chapterTitle: map['chapter_title'],
    );
  }
}

class Chapter {
  final int? id;
  final String title;
  final int titleId;
  final List<Article> articles;

  Chapter({
    this.id,
    required this.title,
    required this.titleId,
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
  final List<TitleStruct> titles;

  Book({
    this.id,
    required this.title,
    this.titles = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
    );
  }
}
