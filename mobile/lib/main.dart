import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'login_page.dart';
import 'pages/quran_page.dart';
import 'pages/zikirmatik_page.dart';
import 'pages/prayer_page.dart';
import 'pages/settings_page.dart';
import 'pages/main_page.dart';
import 'register_page.dart';
import 'config/app_theme.dart';
import 'utils/theme_manager.dart';
import 'utils/language_manager.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final themeManager = ThemeManager();
  final languageManager = LanguageManager();
  final notificationService = NotificationService();

  await Future.wait([
    themeManager.loadTheme(),
    languageManager.loadLanguage(),
    notificationService.init(),
  ]);

  runApp(
    ManeviRehberApp(
      themeManager: themeManager,
      languageManager: languageManager,
    ),
  );
}

class ManeviRehberApp extends StatelessWidget {
  final ThemeManager themeManager;
  final LanguageManager languageManager;

  const ManeviRehberApp({
    super.key,
    required this.themeManager,
    required this.languageManager,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeManager, languageManager]),
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(themeManager.primaryColor),
          darkTheme: AppTheme.darkTheme(themeManager.primaryColor),
          themeMode: themeManager.themeMode,
          locale: languageManager.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ClipRRect(
                key: ValueKey(languageManager.locale.languageCode),
                child: child,
              ),
            );
          },
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/home': (context) => const MainPage(),
            '/quran': (context) => const QuranPage(),
            '/zikirmatik': (context) => const ZikirmatikPage(),
            '/prayer': (context) => const PrayerPage(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
