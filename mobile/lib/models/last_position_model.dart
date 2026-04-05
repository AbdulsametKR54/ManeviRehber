class LastPositionModel {
  final String surahName;
  final int ayahNumber;

  LastPositionModel({
    required this.surahName,
    required this.ayahNumber,
  });

  factory LastPositionModel.fromJson(Map<String, dynamic> json) {
    return LastPositionModel(
      surahName: json['surahName'] as String? ?? '',
      ayahNumber: json['ayahNumber'] as int? ?? 1,
    );
  }
}
