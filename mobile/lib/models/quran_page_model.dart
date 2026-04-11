class AcikKuranPageResponse {
  final List<AcikKuranVerse> data;

  AcikKuranPageResponse({required this.data});

  factory AcikKuranPageResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<AcikKuranVerse> dataList = list.map((i) => AcikKuranVerse.fromJson(i)).toList();
    return AcikKuranPageResponse(data: dataList);
  }
}

class AcikKuranVerse {
  final int id;
  final AcikKuranSurah surah;
  final int verseNumber;
  final String verse;
  final String? verseSimplified;
  final AcikKuranZero? zero;
  final int page;
  final int juzNumber;
  final String transcription;
  final AcikKuranTranslation translation;

  AcikKuranVerse({
    required this.id,
    required this.surah,
    required this.verseNumber,
    required this.verse,
    this.verseSimplified,
    this.zero,
    required this.page,
    required this.juzNumber,
    required this.transcription,
    required this.translation,
  });

  factory AcikKuranVerse.fromJson(Map<String, dynamic> json) {
    return AcikKuranVerse(
      id: json['id'],
      surah: AcikKuranSurah.fromJson(json['surah']),
      verseNumber: json['verse_number'],
      verse: json['verse'],
      verseSimplified: json['verse_simplified'],
      zero: json['zero'] != null ? AcikKuranZero.fromJson(json['zero']) : null,
      page: json['page'],
      juzNumber: json['juz_number'],
      transcription: json['transcription'] ?? '',
      translation: AcikKuranTranslation.fromJson(json['translation']),
    );
  }
}

class AcikKuranSurah {
  final int id;
  final String name;
  final String nameEn;
  final String slug;
  final int verseCount;
  final int pageNumber;
  final String nameOriginal;

  AcikKuranSurah({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.slug,
    required this.verseCount,
    required this.pageNumber,
    required this.nameOriginal,
  });

  factory AcikKuranSurah.fromJson(Map<String, dynamic> json) {
    return AcikKuranSurah(
      id: json['id'],
      name: json['name'],
      nameEn: json['name_en'],
      slug: json['slug'],
      verseCount: json['verse_count'],
      pageNumber: json['page_number'],
      nameOriginal: json['name_original'],
    );
  }
}

class AcikKuranZero {
  final int id;
  final int surahId;
  final int verseNumber;
  final String verse;
  final String transcription;
  final AcikKuranTranslation translation;

  AcikKuranZero({
    required this.id,
    required this.surahId,
    required this.verseNumber,
    required this.verse,
    required this.transcription,
    required this.translation,
  });

  factory AcikKuranZero.fromJson(Map<String, dynamic> json) {
    return AcikKuranZero(
      id: json['id'],
      surahId: json['surah_id'],
      verseNumber: json['verse_number'],
      verse: json['verse'],
      transcription: json['transcription'] ?? '',
      translation: AcikKuranTranslation.fromJson(json['translation']),
    );
  }
}

class AcikKuranTranslation {
  final int id;
  final String text;
  final List<AcikKuranFootnote>? footnotes;

  AcikKuranTranslation({
    required this.id,
    required this.text,
    this.footnotes,
  });

  factory AcikKuranTranslation.fromJson(Map<String, dynamic> json) {
    var footnotesJson = json['footnotes'] as List?;
    return AcikKuranTranslation(
      id: json['id'],
      text: json['text'],
      footnotes: footnotesJson?.map((f) => AcikKuranFootnote.fromJson(f)).toList(),
    );
  }
}

class AcikKuranFootnote {
  final int id;
  final String text;
  final int number;

  AcikKuranFootnote({
    required this.id,
    required this.text,
    required this.number,
  });

  factory AcikKuranFootnote.fromJson(Map<String, dynamic> json) {
    return AcikKuranFootnote(
      id: json['id'],
      text: json['text'],
      number: json['number'],
    );
  }
}
