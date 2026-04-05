class PrayerTimesModel {
  final String nextPrayer;
  final String countdown;
  final Map<String, String> times;

  PrayerTimesModel({
    required this.nextPrayer,
    required this.countdown,
    required this.times,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    // Backend API PrayerTimeDto fields
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

    // Calculate current time
    final now = DateTime.now();

    // Helper to parse HH:mm:ss to DateTime today
    DateTime parseTime(String timeString) {
      final parts = timeString.split(':');
      int h = 0, m = 0, s = 0;
      if (parts.isNotEmpty) h = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) m = int.tryParse(parts[1]) ?? 0;
      if (parts.length > 2) s = int.tryParse(parts[2]) ?? 0;
      return DateTime(now.year, now.month, now.day, h, m, s);
    }

    String nextP = 'İmsak';
    Duration diff = const Duration();
    bool found = false;

    // Ordered list of prayers
    final prayers = [
      {'name': 'İmsak', 'time': parseTime(fajr.toString())},
      {'name': 'Güneş', 'time': parseTime(sunrise.toString())},
      {'name': 'Öğle', 'time': parseTime(dhuhr.toString())},
      {'name': 'İkindi', 'time': parseTime(asr.toString())},
      {'name': 'Akşam', 'time': parseTime(maghrib.toString())},
      {'name': 'Yatsı', 'time': parseTime(isha.toString())},
    ];

    for (var p in prayers) {
      final pTime = p['time'] as DateTime;
      if (pTime.isAfter(now)) {
        nextP = p['name'] as String;
        diff = pTime.difference(now);
        found = true;
        break;
      }
    }

    // If all prayers today have passed, the next prayer is Fajr tomorrow
    if (!found) {
      nextP = 'İmsak';
      final tomorrowFajr = parseTime(fajr.toString()).add(const Duration(days: 1));
      diff = tomorrowFajr.difference(now);
    }

    // Format countdown HH:mm:ss
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final countdownStr = 
        '${twoDigits(diff.inHours)}:${twoDigits(diff.inMinutes.remainder(60))}:${twoDigits(diff.inSeconds.remainder(60))}';

    return PrayerTimesModel(
      nextPrayer: nextP,
      countdown: countdownStr,
      times: timesMap,
    );
  }
}
