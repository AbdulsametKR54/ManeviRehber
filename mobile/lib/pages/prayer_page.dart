import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

import '../services/prayer_service.dart';
import '../models/prayer_times_model.dart';
import '../models/daily_table_model.dart';
import '../utils/image_utils.dart';
import '../services/location_service.dart';
import '../utils/location_manager.dart';
import 'location_selection_page.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/special_day_model.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> with WidgetsBindingObserver {
  int _selectedSegment = 0; // 0: Günlük, 1: Haftalık, 2: Aylık

  PrayerTimesModel? _prayerData;
  List<DailyTableModel>? _monthlyData;
  List<SpecialDayModel>? _specialDays;
  bool _isLoading = true;
  Timer? _timer;
  late String _bgImage;
  String _locationName = '';

  final PrayerService _prayerService = PrayerService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocationManager().addListener(_fetchData);
    _bgImage = ImageUtils.getRandomCamiImage();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocationManager().removeListener(_fetchData);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _bgImage = ImageUtils.getRandomCamiImage();
    });
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        _prayerService.getTimes(),
        _prayerService.getMonthlyTimes(now.year, now.month),
        _locationService.getSelectedLocationName(),
      ]);
      if (mounted) {
        setState(() {
          _prayerData = results[0] as PrayerTimesModel?;
          _monthlyData = results[1] as List<DailyTableModel>?;
          _locationName = (results[2] as String?) ?? ''; 
        });
        
        // Fetch special days separately or as part of Future.wait
        final specialDays = await _prayerService.getSpecialDays();
        if (mounted) {
          setState(() {
            _specialDays = specialDays;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // debugPrint("PrayerPage Fetch Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getLiveCountdown() {
    if (_prayerData == null) return "00:00:00";

    final now = DateTime.now();
    DateTime parseTime(String timeString) {
      final parts = timeString.split(':');
      int h = 0, m = 0, s = 0;
      if (parts.isNotEmpty) h = int.tryParse(parts[0]) ?? 0;
      if (parts.length > 1) m = int.tryParse(parts[1]) ?? 0;
      if (parts.length > 2) s = int.tryParse(parts[2]) ?? 0;
      return DateTime(now.year, now.month, now.day, h, m, s);
    }

    Duration diff = const Duration();
    bool found = false;

    final prayers = [
      {
        'name': 'İmsak',
        'time': parseTime(_prayerData!.times['İmsak'] ?? '00:00:00'),
      },
      {
        'name': 'Güneş',
        'time': parseTime(_prayerData!.times['Güneş'] ?? '00:00:00'),
      },
      {
        'name': 'Öğle',
        'time': parseTime(_prayerData!.times['Öğle'] ?? '00:00:00'),
      },
      {
        'name': 'İkindi',
        'time': parseTime(_prayerData!.times['İkindi'] ?? '00:00:00'),
      },
      {
        'name': 'Akşam',
        'time': parseTime(_prayerData!.times['Akşam'] ?? '00:00:00'),
      },
      {
        'name': 'Yatsı',
        'time': parseTime(_prayerData!.times['Yatsı'] ?? '00:00:00'),
      },
    ];

    for (var p in prayers) {
      final pTime = p['time'] as DateTime;
      if (pTime.isAfter(now)) {
        diff = pTime.difference(now);
        found = true;
        break;
      }
    }

    if (!found) {
      final tomorrowFajr = parseTime(
        _prayerData!.times['İmsak'] ?? '00:00:00',
      ).add(const Duration(days: 1));
      diff = tomorrowFajr.difference(now);
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(diff.inHours)}:${twoDigits(diff.inMinutes.remainder(60))}:${twoDigits(diff.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
              elevation: 0,
              centerTitle: false,
              title: GestureDetector(
                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationSelectionPage(),
                    ),
                  );
                  if (changed == true) {
                    _fetchData();
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      _locationName.isEmpty ? l10n.locationFallback : _locationName,
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: 'Noto Serif',
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Icon(Icons.notifications, color: colorScheme.onSurface),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
              top: 100,
              bottom: 120,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroCountdown(),
                const SizedBox(height: 16),
                _buildPrayerGrid(),
                const SizedBox(height: 24),
                _buildSegmentedControl(),
                const SizedBox(height: 24),
                if (_selectedSegment == 3)
                  _buildSpecialDaysList()
                else
                  _buildWeeklyTable(),
                const SizedBox(height: 48),
                _buildReminderSettings(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getLocalizedPrayerName(String name, AppLocalizations l10n) {
    switch (name) {
      case 'İmsak':
        return l10n.imsak;
      case 'Güneş':
        return l10n.gunes;
      case 'Öğle':
        return l10n.ogle;
      case 'İkindi':
        return l10n.ikindi;
      case 'Akşam':
        return l10n.aksam;
      case 'Yatsı':
        return l10n.yatsi;
      default:
        return l10n.unknown;
    }
  }

  Widget _buildHeroCountdown() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading || _prayerData == null) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final nextPrayer = _prayerData!.nextPrayer;
    final liveCountdown = _getLiveCountdown();
    final nextTime = _prayerData!.times[nextPrayer] ?? '00:00';
    final parsedNextTime = nextTime; // Already formatted as HH:mm in model

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFE2E2E2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset(_bgImage, fit: BoxFit.cover)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nextTime,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      getLocalizedPrayerName(_prayerData!.nextPrayer, l10n),
                      style: const TextStyle(
                        fontFamily: 'Noto Serif',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      parsedNextTime,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '$liveCountdown ${l10n.left}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerGrid() {
    if (_isLoading || _prayerData == null) {
      return const SizedBox(height: 100);
    }

    final l10n = AppLocalizations.of(context)!;
    final prayers = [
      {'label': l10n.imsak, 'key': 'İmsak'},
      {'label': l10n.gunes, 'key': 'Güneş'},
      {'label': l10n.ogle, 'key': 'Öğle'},
      {'label': l10n.ikindi, 'key': 'İkindi'},
      {'label': l10n.aksam, 'key': 'Akşam'},
      {'label': l10n.yatsi, 'key': 'Yatsı'},
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: prayers.length,
      itemBuilder: (context, index) {
        final prayer = prayers[index];
        final label = prayer['label']!;
        final time = _prayerData!.times[prayer['key']] ?? '00:00'; // Already formatted HH:mm

        final isActive = _prayerData!.nextPrayer == prayer['key'];

        return Container(
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  )
                : Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.05),
                  ),
            boxShadow: isActive
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use a slightly bolder label for better readability
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentedControl() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          _buildSegmentItem(0, l10n.daily),
          _buildSegmentItem(1, l10n.weekly),
          _buildSegmentItem(2, l10n.monthly),
          _buildSegmentItem(3, l10n.specialDays),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(int index, String label) {
    bool isSelected = _selectedSegment == index;
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSegment = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyTable() {
    if (_isLoading || _monthlyData == null || _monthlyData!.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFF006A40)),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<DailyTableModel> filteredData = [];

    if (_selectedSegment == 0) {
      // Günlük
      filteredData = _monthlyData!
          .where((d) => d.date.isAtSameMomentAs(today))
          .toList();
    } else if (_selectedSegment == 1) {
      // Haftalık
      final startDate = today.subtract(const Duration(days: 2));
      final endDate = today.add(const Duration(days: 4));
      filteredData = _monthlyData!.where((d) {
        return d.date.compareTo(startDate) >= 0 &&
            d.date.compareTo(endDate) <= 0;
      }).toList();
    } else if (_selectedSegment == 2) {
      // Aylık
      filteredData = _monthlyData!;
    }

    filteredData.sort((a, b) => a.date.compareTo(b.date));

    final l10n = AppLocalizations.of(context)!;

    String formatDate(DateTime d) {
      if (d.isAtSameMomentAs(today)) return l10n.today;
      
      String mName = '';
      switch (d.month) {
        case 1: mName = l10n.month1Short; break;
        case 2: mName = l10n.month2Short; break;
        case 3: mName = l10n.month3Short; break;
        case 4: mName = l10n.month4Short; break;
        case 5: mName = l10n.month5Short; break;
        case 6: mName = l10n.month6Short; break;
        case 7: mName = l10n.month7Short; break;
        case 8: mName = l10n.month8Short; break;
        case 9: mName = l10n.month9Short; break;
        case 10: mName = l10n.month10Short; break;
        case 11: mName = l10n.month11Short; break;
        case 12: mName = l10n.month12Short; break;
      }
      
      return '${d.day} $mName';
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
            6: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
              children: [
                _buildTableCellHeader(context, l10n.date),
                _buildTableCellHeader(context, l10n.imsak.substring(0, 3)),
                _buildTableCellHeader(context, l10n.gunes.substring(0, 3)),
                _buildTableCellHeader(context, l10n.ogle.substring(0, 3)),
                _buildTableCellHeader(context, l10n.ikindi.substring(0, 3)),
                _buildTableCellHeader(context, l10n.aksam.substring(0, 3)),
                _buildTableCellHeader(context, l10n.yatsi.substring(0, 3)),
              ],
            ),
            for (var row in filteredData)
              TableRow(
                decoration: BoxDecoration(
                  color: row.isToday
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                children: [
                  _buildTableCellData(
                    context,
                    formatDate(row.date),
                    isBold: true,
                    isToday: row.isToday,
                  ),
                  ...([
                    'İmsak',
                    'Güneş',
                    'Öğle',
                    'İkindi',
                    'Akşam',
                    'Yatsı',
                  ].map((key) {
                    final parsed = row.times[key] ?? '00:00'; // Already formatted HH:mm
                    return _buildTableCellData(
                      context,
                      parsed,
                      isToday: row.isToday,
                    );
                  }).toList()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCellHeader(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text.toUpperCase(),
        textAlign: TextAlign.left,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildTableCellData(
    BuildContext context,
    String text, {
    bool isBold = false,
    bool isToday = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: isBold || isToday ? FontWeight.w700 : FontWeight.w500,
          color: isToday
              ? colorScheme.primary
              : (isBold
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      ),
    );
  }

  Widget _buildReminderSettings() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.notificationSettings,
              style: textTheme.titleLarge?.copyWith(
                fontFamily: 'Noto Serif',
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Icon(Icons.tune, color: colorScheme.primary),
          ],
        ),
        const SizedBox(height: 16),
        _buildReminderItem(Icons.wb_twilight, l10n.imsakReminder, true),
        const SizedBox(height: 12),
        _buildReminderItem(Icons.light_mode, l10n.ogleReminder, false),
        const SizedBox(height: 12),
        _buildReminderItem(Icons.bedtime, l10n.yatsiReminder, true),
      ],
    );
  }

  Widget _buildReminderItem(IconData icon, String title, bool isEnabled) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: isEnabled
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: isEnabled ? 22 : 2,
                  top: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialDaysList() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    if (_specialDays == null || _specialDays!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(Icons.event_note, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n.contentLoadError,
              style: TextStyle(
                fontFamily: 'Manrope',
                color: colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return Column(
      children: _specialDays!.map((day) {
        final isPast = day.date.isBefore(today);
        final isToday = day.date.year == today.year && 
                       day.date.month == today.month && 
                       day.date.day == today.day;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isToday 
                ? colorScheme.primary.withValues(alpha: 0.05)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isToday 
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isPast 
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.date.day.toString(),
                        style: TextStyle(
                          fontFamily: 'Noto Serif',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isPast ? colorScheme.outline : colorScheme.primary,
                        ),
                      ),
                      Text(
                        _getMonthShortName(day.date.month, l10n).toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isPast ? colorScheme.outline : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.name,
                        style: TextStyle(
                          fontFamily: 'Noto Serif',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isPast 
                            ? colorScheme.onSurface.withValues(alpha: 0.6)
                            : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.description,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isPast)
                  Icon(
                    Icons.star,
                    size: 16,
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getMonthShortName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1: return l10n.month1Short;
      case 2: return l10n.month2Short;
      case 3: return l10n.month3Short;
      case 4: return l10n.month4Short;
      case 5: return l10n.month5Short;
      case 6: return l10n.month6Short;
      case 7: return l10n.month7Short;
      case 8: return l10n.month8Short;
      case 9: return l10n.month9Short;
      case 10: return l10n.month10Short;
      case 11: return l10n.month11Short;
      case 12: return l10n.month12Short;
      default: return '';
    }
  }
}
