class DailyTableModel {
  final DateTime date;
  final Map<String, String> times;
  
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  DailyTableModel({
    required this.date,
    required this.times,
  });

  factory DailyTableModel.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] ?? json['Date'];
    DateTime parsedDate;
    if (dateStr is String) {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        parsedDate = DateTime(
          int.tryParse(parts[0]) ?? 2000,
          int.tryParse(parts[1]) ?? 1,
          int.tryParse(parts[2].substring(0, 2)) ?? 1,
        );
      } else {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    final fajr = json['fajr'] ?? json['Fajr'] ?? '00:00:00';
    final sunrise = json['sunrise'] ?? json['Sunrise'] ?? '00:00:00';
    final dhuhr = json['dhuhr'] ?? json['Dhuhr'] ?? '00:00:00';
    final asr = json['asr'] ?? json['Asr'] ?? '00:00:00';
    final maghrib = json['maghrib'] ?? json['Maghrib'] ?? '00:00:00';
    final isha = json['isha'] ?? json['Isha'] ?? '00:00:00';

    String formatTime(String time) {
      if (time.length > 5) {
        final parts = time.split(':');
        return '${parts[0]}:${parts[1]}';
      }
      return time;
    }

    final Map<String, String> timesMap = {
      'İmsak': formatTime(fajr.toString()),
      'Güneş': formatTime(sunrise.toString()),
      'Öğle': formatTime(dhuhr.toString()),
      'İkindi': formatTime(asr.toString()),
      'Akşam': formatTime(maghrib.toString()),
      'Yatsı': formatTime(isha.toString()),
    };

    return DailyTableModel(
      date: parsedDate,
      times: timesMap,
    );
  }
}
