class DailyVerseModel {
  final String arabic;
  final String translation;
  final String surahName;
  final int? surahId;
  final int ayahNumber;

  DailyVerseModel({
    required this.arabic,
    required this.translation,
    required this.surahName,
    this.surahId,
    required this.ayahNumber,
  });

  factory DailyVerseModel.fromJson(Map<String, dynamic> json, String surahName, {int? surahId}) {
    // Handle VerseDetailDto from OpenApi Proxy
    // or AyahDto from internal service
    
    // Arabic text can be in 'verse' (OpenApi), 'text' (Internal) or 'arabic' (Old/Other)
    final arabicText = (json['verse'] ?? json['Verse'] ?? json['text'] ?? json['Text'] ?? json['arabic'] ?? json['Arabic'] ?? '').toString();
    
    // Translation can be in 'translation']['text'] (OpenApi) or 'translation' (Internal/Other)
    String translationText = 'Meal bulunamadı.';
    final translationObj = json['translation'] ?? json['Translation'];
    if (translationObj is Map) {
      translationText = (translationObj['text'] ?? translationObj['Text'] ?? 'Meal bulunamadı.').toString();
    } else if (translationObj is String) {
      translationText = translationObj;
    }

    // Ayah number can be 'verse_number' (OpenApi returns this), 'verseNumber' etc.
    final number = (json['verse_number'] ?? json['verseNumber'] ?? json['VerseNumber'] ?? json['ayahNumber'] ?? json['AyahNumber'] ?? 1) as int;

    return DailyVerseModel(
      arabic: arabicText,
      translation: translationText,
      surahName: surahName,
      surahId: surahId,
      ayahNumber: number,
    );
  }
}
