import 'dart:async';
import 'package:flutter/material.dart';
import '../models/prayer_times_model.dart';
import '../utils/image_utils.dart';
import '../l10n/generated/app_localizations.dart';

class PrayerCard extends StatefulWidget {
  final PrayerTimesModel? model;
  final bool isLoading;

  const PrayerCard({
    super.key,
    this.model,
    this.isLoading = false,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  Timer? _timer;
  String _liveNextPrayer = '';
  String _liveCountdown = '00:00:00';
  late String _bgImage;

  @override
  void initState() {
    super.initState();
    _bgImage = ImageUtils.getRandomCamiImage();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void didUpdateWidget(covariant PrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model && widget.model != null) {
      _bgImage = ImageUtils.getRandomCamiImage();
      _updateTime();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (widget.model == null) return;
    
    final now = DateTime.now();
    final times = widget.model!.times;
    
    DateTime parseTime(String timeString) {
      final parts = timeString.split(':');
      int h = 0, m = 0, s = 0;
      if (parts.isNotEmpty) h = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) m = int.tryParse(parts[1]) ?? 0;
      if (parts.length > 2) s = int.tryParse(parts[2]) ?? 0;
      return DateTime(now.year, now.month, now.day, h, m, s);
    }

    final prayers = [
      {'name': 'İmsak', 'time': parseTime(times['İmsak'] ?? '00:00')},
      {'name': 'Güneş', 'time': parseTime(times['Güneş'] ?? '00:00')},
      {'name': 'Öğle', 'time': parseTime(times['Öğle'] ?? '00:00')},
      {'name': 'İkindi', 'time': parseTime(times['İkindi'] ?? '00:00')},
      {'name': 'Akşam', 'time': parseTime(times['Akşam'] ?? '00:00')},
      {'name': 'Yatsı', 'time': parseTime(times['Yatsı'] ?? '00:00')},
    ];

    bool found = false;
    for (var p in prayers) {
      final pTime = p['time'] as DateTime;
      if (pTime.isAfter(now)) {
        _liveNextPrayer = p['name'] as String;
        final diff = pTime.difference(now);
        _liveCountdown = _formatDuration(diff);
        found = true;
        break;
      }
    }

    if (!found) {
      _liveNextPrayer = 'İmsak';
      final tomorrowFajr = parseTime(times['İmsak'] ?? '00:00').add(const Duration(days: 1));
      final diff = tomorrowFajr.difference(now);
      _liveCountdown = _formatDuration(diff);
    }

    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (widget.isLoading) {
      return Container(
        height: 192,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    
    String getLocalizedPrayerName(String name) {
      switch (name) {
        case 'İmsak': return l10n.imsak;
        case 'Güneş': return l10n.gunes;
        case 'Öğle': return l10n.ogle;
        case 'İkindi': return l10n.ikindi;
        case 'Akşam': return l10n.aksam;
        case 'Yatsı': return l10n.yatsi;
        default: return l10n.unknown;
      }
    }

    final nextPrayerTechnical = widget.model != null ? _liveNextPrayer : 'Bilinmiyor';
    final nextPrayerDisplay = getLocalizedPrayerName(nextPrayerTechnical);
    final countdown = widget.model != null ? _liveCountdown : '00:00:00';

    return Container(
      height: 192,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceVariant,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
             child: Image.asset(
               _bgImage,
               fit: BoxFit.cover,
               errorBuilder: (context, error, stackTrace) => Container(color: colorScheme.outline),
             ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.nextPrayerIn(nextPrayerDisplay),
                      style: const TextStyle(
                        fontFamily: 'Noto Serif',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.remainingTime,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Text(
                  countdown,
                  style: const TextStyle(
                    fontFamily: 'Noto Serif',
                    fontSize: 30, // 3xl loosely
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5, // tracking-tight
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

