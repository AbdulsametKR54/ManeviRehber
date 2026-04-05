import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/language_manager.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../widgets/bottom_nav.dart';
import 'home_page.dart';
import 'quran_page.dart';
import 'prayer_page.dart';
import 'settings_page.dart';
import 'daily_content_page.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  Timer? _widgetUpdateTimer;

  @override
  void initState() {
    super.initState();
    // Sync language from DB on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LanguageManager().syncWithProfile();
      _startWidgetTimer();
    });
  }

  @override
  void dispose() {
    _widgetUpdateTimer?.cancel();
    super.dispose();
  }

  void _startWidgetTimer() {
    _widgetUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateWidgetIfEnabled();
    });
    _updateWidgetIfEnabled(); // Initial update
  }

  Future<void> _updateWidgetIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final bool enableWidget = prefs.getBool('enable_prayer_widget') ?? false;
    
    if (enableWidget) {
      final prayerService = PrayerService();
      final times = await prayerService.getTimes();
      if (times != null) {
        await NotificationService().showPrayerTimesWidget(times);
      }
    }
  }

  final List<Widget> _pages = [
    const HomePage(),
    const QuranPage(),
    const DailyContentPage(),
    const PrayerPage(),

    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
