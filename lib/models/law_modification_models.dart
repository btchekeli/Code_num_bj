class LawModification {
  final String id;
  final String title;
  final String subtitle;
  final String dateAdoption;
  final String datePromulgation;
  final String promulgator;
  final List<Signatory> signatories;
  final List<ModifyingArticle> articles;

  LawModification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateAdoption,
    required this.datePromulgation,
    required this.promulgator,
    required this.signatories,
    required this.articles,
  });

  factory LawModification.fromJson(Map<String, dynamic> json) {
    final sigList = json['signatories'] as List? ?? [];
    final artList = json['articles'] as List? ?? [];
    return LawModification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      dateAdoption: json['date_adoption'] ?? '',
      datePromulgation: json['date_promulgation'] ?? '',
      promulgator: json['promulgator'] ?? '',
      signatories: sigList.map((e) => Signatory.fromJson(e)).toList(),
      articles: artList.map((e) => ModifyingArticle.fromJson(e)).toList(),
    );
  }
}

class Signatory {
  final String name;
  final String role;

  Signatory({required this.name, required this.role});

  factory Signatory.fromJson(Map<String, dynamic> json) {
    return Signatory(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class ModifyingArticle {
  final String numero;
  final String? description;
  final String? texte; // for simple text articles
  final List<ArticleModification>? modifications; // for articles containing multiple sub-modifications

  ModifyingArticle({
    required this.numero,
    this.description,
    this.texte,
    this.modifications,
  });

  factory ModifyingArticle.fromJson(Map<String, dynamic> json) {
    final modList = json['modifications'] as List?;
    return ModifyingArticle(
      numero: json['numero'] ?? '',
      description: json['description'],
      texte: json['texte'],
      modifications: modList?.map((e) => ArticleModification.fromJson(e)).toList(),
    );
  }
}

class ArticleModification {
  final String articleOriginal;
  final String titre;
  final String nouveauTexte;

  ArticleModification({
    required this.articleOriginal,
    required this.titre,
    required this.nouveauTexte,
  });

  factory ArticleModification.fromJson(Map<String, dynamic> json) {
    return ArticleModification(
      articleOriginal: json['article_original'] ?? '',
      titre: json['titre'] ?? '',
      nouveauTexte: json['nouveau_texte'] ?? '',
    );
  }
}
