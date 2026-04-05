class SurahModel {
  final int id;
  final String name;
  final String turkishName;
  final int ayahCount;

  SurahModel({
    required this.id,
    required this.name,
    required this.turkishName,
    required this.ayahCount,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: (json['id'] ?? json['Id'] ?? 0) as int,
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      turkishName: (json['turkishName'] ?? json['TurkishName'] ?? json['name'] ?? json['Name'] ?? 'Bilinmiyor').toString(),
      ayahCount: (json['ayahCount'] ?? json['AyahCount'] ?? 0) as int,
    );
  }
}
