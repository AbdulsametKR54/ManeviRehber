enum ZikrPhrase {
  subhanallah,
  elhamdulillah,
  allahuEkber,
  laIlaheIllallah,
  estagfirullah,
}

extension ZikrPhraseExtension on ZikrPhrase {
  String get key {
    switch (this) {
      case ZikrPhrase.subhanallah: return 'subhanallah';
      case ZikrPhrase.elhamdulillah: return 'elhamdulillah';
      case ZikrPhrase.allahuEkber: return 'allahu-ekber';
      case ZikrPhrase.laIlaheIllallah: return 'la-ilahe-illallah';
      case ZikrPhrase.estagfirullah: return 'estağfirullah';
    }
  }

  static ZikrPhrase fromKey(String key) {
    final normalized = key.trim().toLowerCase();
    return ZikrPhrase.values.firstWhere(
      (e) => e.key.toLowerCase() == normalized || e.name.toLowerCase() == normalized,
      orElse: () => ZikrPhrase.subhanallah,
    );
  }
}

class ZikrDailySummary {
  final DateTime date;
  final String phrase;
  final int total;

  ZikrDailySummary({
    required this.date,
    required this.phrase,
    required this.total,
  });

  factory ZikrDailySummary.fromJson(Map<String, dynamic> json) {
    return ZikrDailySummary(
      date: DateTime.parse(json['date'] ?? json['Date']),
      phrase: (json['phrase'] ?? json['Phrase'] ?? '') as String,
      total: (json['total'] ?? json['Total'] ?? 0) as int,
    );
  }
}
