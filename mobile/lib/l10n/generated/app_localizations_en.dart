// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Spiritual Guide';

  @override
  String get navHome => 'Home';

  @override
  String get navQuran => 'Quran';

  @override
  String get navZikir => 'Tasbih';

  @override
  String get navDaily => 'Daily';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language (App)';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get imsak => 'Imsak';

  @override
  String get gunes => 'Sunrise';

  @override
  String get ogle => 'Dhuhr';

  @override
  String get ikindi => 'Asr';

  @override
  String get aksam => 'Maghrib';

  @override
  String get yatsi => 'Isha';

  @override
  String get unknown => 'Unknown';

  @override
  String nextPrayerIn(String prayer) {
    return 'To $prayer Adhan';
  }

  @override
  String get remainingTime => 'Remaining Time';

  @override
  String get change => 'Change';

  @override
  String get nextTime => 'NEXT PRAYER';

  @override
  String get left => 'left';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get today => 'Today';

  @override
  String get date => 'Date';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get imsakReminder => 'Imsak Reminder';

  @override
  String get ogleReminder => 'Dhuhr Reminder';

  @override
  String get yatsiReminder => 'Isha Reminder';

  @override
  String get dailyContentHeader => 'Today\'s Content';

  @override
  String get contentTypeAyah => 'CONTENT TYPE: AYAH';

  @override
  String get contentTypeQuote => 'CONTENT TYPE: QUOTE';

  @override
  String get dailyQuote => 'Quote of the Day';

  @override
  String get spiritualPearls => 'Spiritual Pearls';

  @override
  String get settingsLanguageSection => 'Language (App)';

  @override
  String get settingsTheme => 'THEME';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsTextSize => 'TEXT SIZE';

  @override
  String get settingsProfile => 'My Profile';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsNotification => 'Notification Time';

  @override
  String get settingsNotificationAtTime => 'At Time';

  @override
  String get settingsDailyContent => 'Appearance';

  @override
  String get settingsShareFormat => 'SHARE FORMAT';

  @override
  String get settingsShareFormatImage => 'Image';

  @override
  String get settingsShareFormatText => 'Text';

  @override
  String get settingsBgTheme => 'Background Theme';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms of Use';

  @override
  String get settingsDeveloper => 'About Developer';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get saved => 'Saved';

  @override
  String get sharing => 'Sharing...';

  @override
  String get zikirmatik => 'Tasbih';

  @override
  String get zikirmatikSub => 'Easily track your tasbih counter.';

  @override
  String get reset => 'RESET';

  @override
  String get goalProgress => 'GOAL PROGRESS';

  @override
  String get zikrSaved => 'Zikr saved!';

  @override
  String get qiblaFinder => 'Qibla Finder';

  @override
  String get contentLoadError => 'Content could not be loaded.';

  @override
  String get chatTitle => 'Spiritual Guide Chat';

  @override
  String get chatSub => 'Explore your religious questions with AI.';

  @override
  String get startChat => 'Start Chat';

  @override
  String get loginWelcome => 'Continue your spiritual journey.';

  @override
  String get email => 'EMAIL';

  @override
  String get emailHint => 'example@mail.com';

  @override
  String get password => 'PASSWORD';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Login';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerNow => 'Register';

  @override
  String get serenity => 'Serenity';

  @override
  String get faith => 'Faith';

  @override
  String get belief => 'Belief';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerWelcome => 'Start a new journey.';

  @override
  String get fullName => 'FULL NAME';

  @override
  String get fullNameHint => 'Full Name';

  @override
  String get registerButton => 'Register';

  @override
  String get registering => 'Registering...';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get loginNow => 'Login';

  @override
  String get registerSuccess => 'Registration successful! You can now login.';

  @override
  String get registerFail => 'Registration failed';

  @override
  String get loginFail => 'Login failed';

  @override
  String get language => 'LANGUAGE';

  @override
  String get quranHeader => 'Holy Quran';

  @override
  String get searchSurah => 'Search Surah...';

  @override
  String ayahCount(int count) {
    return '$count Ayahs';
  }

  @override
  String get detail => 'Detail';

  @override
  String get surahNotFound => 'Surah not found.';

  @override
  String get lastRead => 'LAST READ';

  @override
  String get surah => 'Surah';

  @override
  String get ayah => 'Verse';

  @override
  String get surahDetail => 'Surah Detail';

  @override
  String get loadingRecitation => 'Loading recitation...';

  @override
  String get audioNotFound => 'Audio file not found.';

  @override
  String get translationStarted => 'Translation started';

  @override
  String get selectReciter => 'Select Reciter';

  @override
  String get loading => 'Loading...';

  @override
  String get listenRecitation => 'Listen Recitation';

  @override
  String get listenTranslation => 'Listen Translation';

  @override
  String get listenAyah => 'Listen Verse';

  @override
  String get ayahsNotLoaded => 'Verses could not be loaded.';

  @override
  String get saving => 'Saving...';

  @override
  String get accAndApp => 'ACCOUNT & APP';

  @override
  String get customizeExperience =>
      'Personalize Your Spiritual Guide Experience.';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeMedium => 'Medium';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get month1 => 'January';

  @override
  String get month2 => 'February';

  @override
  String get month3 => 'March';

  @override
  String get month4 => 'April';

  @override
  String get month5 => 'May';

  @override
  String get month6 => 'June';

  @override
  String get month7 => 'July';

  @override
  String get month8 => 'August';

  @override
  String get month9 => 'September';

  @override
  String get month10 => 'October';

  @override
  String get month11 => 'November';

  @override
  String get month12 => 'December';

  @override
  String get month1Short => 'Jan';

  @override
  String get month2Short => 'Feb';

  @override
  String get month3Short => 'Mar';

  @override
  String get month4Short => 'Apr';

  @override
  String get month5Short => 'May';

  @override
  String get month6Short => 'Jun';

  @override
  String get month7Short => 'Jul';

  @override
  String get month8Short => 'Aug';

  @override
  String get month9Short => 'Sep';

  @override
  String get month10Short => 'Oct';

  @override
  String get month11Short => 'Nov';

  @override
  String get month12Short => 'Dec';

  @override
  String versionInfo(String version) {
    return 'Version $version';
  }

  @override
  String get edit => 'Edit';

  @override
  String get subhanallah => 'Subhanallah';

  @override
  String get alhamdulillah => 'Alhamdulillah';

  @override
  String get allahuAkbar => 'Allahu Akbar';

  @override
  String get laIlaheIllallah => 'La ilaha illa Allah';

  @override
  String get estagfirullah => 'Astaghfirullah';

  @override
  String get loadingPoints => 'Loading...';

  @override
  String get locationFallback => 'Maltepe, Istanbul';

  @override
  String get sharePreview => 'Share Preview';

  @override
  String get selectBackground => 'Select Background';

  @override
  String get shareAsImage => 'Share as Image';

  @override
  String get contentVerse => 'Verse';

  @override
  String get contentHadith => 'Hadith';

  @override
  String get contentQuote => 'Quote';

  @override
  String get contentPrayer => 'Prayer';

  @override
  String get specialDays => 'Special Days';

  @override
  String get settingsReminder15Min => 'Remind 15 Min Before (Vibrate)';

  @override
  String get settingsAthanSound => 'Play Athan Sound';

  @override
  String get settingsAthanDesc =>
      'Play the Athan sound when it is prayer time.';
}
