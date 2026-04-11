import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/quran_constants.dart';
import 'hatim_page.dart';

import '../widgets/prayer_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/last_read_card.dart';
import '../widgets/chat_invite_card.dart';
import '../widgets/quick_access_grid.dart';
import 'surah_detail_page.dart';
import '../models/surah_model.dart';

import '../services/prayer_service.dart';
import '../services/quran_service.dart';
import '../services/daily_content_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../utils/location_manager.dart';

import '../models/prayer_times_model.dart';
import '../models/daily_verse_model.dart';
import '../models/daily_content_model.dart';

import 'location_selection_page.dart';

enum LoadState { loading, success, error }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  LoadState _prayerLoadState = LoadState.loading;
  LoadState _verseLoadState = LoadState.loading;
  LoadState _progressLoadState = LoadState.loading;

  PrayerTimesModel? _prayerData;
  DailyContentModel? _quoteData;
  DailyVerseModel? _progressData;
  String _locationName = '';
  int _lastHatimPage = 1;
  String _lastHatimSurahName = '...';

  final PrayerService _prayerService = PrayerService();
  final DailyContentService _dailyContentService = DailyContentService();
  final QuranService _quranService = QuranService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocationManager().addListener(_fetchData);
    _fetchData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocationManager().removeListener(_fetchData);
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
      _prayerLoadState = LoadState.loading;
      _verseLoadState = LoadState.loading;
      _progressLoadState = LoadState.loading;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPage = prefs.getInt('last_hatim_page') ?? 1;
      
      final results = await Future.wait([
        _prayerService.getTimes(),
        _dailyContentService.getRandomDailyContent(),
        _quranService.getRandomAyah(),
        _locationService.getSelectedLocationName(),
        _quranService.getSurahs(),
      ]);

      if (!mounted) return;

      setState(() {
        _lastHatimPage = lastPage;
        
        final surahs = results[4] as List<SurahModel>;
        if (surahs.isNotEmpty) {
          int surahId = QuranConstants.getSurahByPage(lastPage);
          final surah = surahs.firstWhere((s) => s.id == surahId, orElse: () => surahs.first);
          _lastHatimSurahName = surah.turkishName;
        }

        _prayerData = results[0] as PrayerTimesModel?;
        _prayerLoadState = _prayerData != null ? LoadState.success : LoadState.error;

        _quoteData = results[1] as DailyContentModel?;
        _verseLoadState = _quoteData != null ? LoadState.success : LoadState.error;

        _progressData = results[2] as DailyVerseModel?;
        _progressLoadState = _progressData != null ? LoadState.success : LoadState.error;

        final locName = results[3] as String?;
        _locationName = locName ?? ''; 

        if (_prayerData != null) {
          NotificationService().schedulePrayerNotifications(_prayerData!);
        }
      });
    } catch (e) {
      debugPrint("HomePage Fetch Error: $e");
      if (mounted) {
        setState(() {
          _prayerLoadState = LoadState.error;
          _verseLoadState = LoadState.error;
          _progressLoadState = LoadState.error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
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
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
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
            ), // pt-20 pb-28
            child: Column(
              children: [
                PrayerCard(
                  model: _prayerData,
                  isLoading: _prayerLoadState == LoadState.loading,
                ),
                const SizedBox(height: 32),
                QuoteCard(
                  model: _quoteData,
                  isLoading: _verseLoadState == LoadState.loading,
                ),
                const SizedBox(height: 32),
                LastReadCard(
                  title: "Sure/Ayet Dinle",
                  model: _progressData,
                  isLoading: _progressLoadState == LoadState.loading,
                  icon: Icons.play_arrow,
                  onTap: () async {
                    if (_progressData == null || _progressData!.surahId == null) return;
                    
                    final List<SurahModel> surahs = await _quranService.getSurahs();
                    if (surahs.isEmpty) return;
                    
                    final SurahModel surah = surahs.firstWhere(
                      (s) => s.id == _progressData!.surahId,
                      orElse: () => surahs.first,
                    );
                    
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailPage(
                            surah: surah,
                            initialAyahNumber: _progressData!.ayahNumber,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                LastReadCard(
                  title: "Hatim: Kaldığın Yer",
                  subtitle: "$_lastHatimSurahName Suresi – Sayfa $_lastHatimPage",
                  icon: Icons.menu_book,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HatimPage(initialPage: _lastHatimPage),
                      ),
                    ).then((_) => _fetchData()); // Refresh progress when returning
                  },
                ),
                const SizedBox(height: 32),
                const ChatInviteCard(),
                const SizedBox(height: 32),
                const QuickAccessGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
