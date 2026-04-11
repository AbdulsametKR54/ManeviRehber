class FavoriteModel {
  final String id;
  final int type; // ContentType enum value from backend
  final String externalId;
  final int? surahId;
  final int? ayahNumber;
  final int? pageNumber;
  final String? title;
  final String? contentArabic;
  final String? contentText;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.type,
    required this.externalId,
    this.surahId,
    this.ayahNumber,
    this.pageNumber,
    this.title,
    this.contentArabic,
    this.contentText,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      type: json['type'],
      externalId: json['externalId'],
      surahId: json['surahId'],
      ayahNumber: json['ayahNumber'],
      pageNumber: json['pageNumber'],
      title: json['title'],
      contentArabic: json['contentArabic'],
      contentText: json['contentText'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'externalId': externalId,
      'surahId': surahId,
      'ayahNumber': ayahNumber,
      'pageNumber': pageNumber,
      'title': title,
      'contentArabic': contentArabic,
      'contentText': contentText,
    };
  }
}
