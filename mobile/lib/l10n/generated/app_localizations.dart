import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Manevi Rehber'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navQuran.
  ///
  /// In tr, this message translates to:
  /// **'Kur’an'**
  String get navQuran;

  /// No description provided for @navZikir.
  ///
  /// In tr, this message translates to:
  /// **'Zikirmatik'**
  String get navZikir;

  /// No description provided for @navDaily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get navDaily;

  /// No description provided for @navPrayer.
  ///
  /// In tr, this message translates to:
  /// **'Namaz'**
  String get navPrayer;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dil (Uygulama)'**
  String get languageTitle;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In tr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @imsak.
  ///
  /// In tr, this message translates to:
  /// **'İmsak'**
  String get imsak;

  /// No description provided for @gunes.
  ///
  /// In tr, this message translates to:
  /// **'Güneş'**
  String get gunes;

  /// No description provided for @ogle.
  ///
  /// In tr, this message translates to:
  /// **'Öğle'**
  String get ogle;

  /// No description provided for @ikindi.
  ///
  /// In tr, this message translates to:
  /// **'İkindi'**
  String get ikindi;

  /// No description provided for @aksam.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get aksam;

  /// No description provided for @yatsi.
  ///
  /// In tr, this message translates to:
  /// **'Yatsı'**
  String get yatsi;

  /// No description provided for @unknown.
  ///
  /// In tr, this message translates to:
  /// **'Bilinmiyor'**
  String get unknown;

  /// No description provided for @nextPrayerIn.
  ///
  /// In tr, this message translates to:
  /// **'{prayer} Ezanına'**
  String nextPrayerIn(String prayer);

  /// No description provided for @remainingTime.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Süre'**
  String get remainingTime;

  /// No description provided for @change.
  ///
  /// In tr, this message translates to:
  /// **'Değiştir'**
  String get change;

  /// No description provided for @nextTime.
  ///
  /// In tr, this message translates to:
  /// **'SIRADAKİ VAKİT'**
  String get nextTime;

  /// No description provided for @left.
  ///
  /// In tr, this message translates to:
  /// **'kaldı'**
  String get left;

  /// No description provided for @daily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get monthly;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @date.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get date;

  /// No description provided for @notificationSettings.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Ayarları'**
  String get notificationSettings;

  /// No description provided for @imsakReminder.
  ///
  /// In tr, this message translates to:
  /// **'İmsak Hatırlatıcı'**
  String get imsakReminder;

  /// No description provided for @ogleReminder.
  ///
  /// In tr, this message translates to:
  /// **'Öğle Hatırlatıcı'**
  String get ogleReminder;

  /// No description provided for @yatsiReminder.
  ///
  /// In tr, this message translates to:
  /// **'Yatsı Hatırlatıcı'**
  String get yatsiReminder;

  /// No description provided for @dailyContentHeader.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün İçeriği'**
  String get dailyContentHeader;

  /// No description provided for @contentTypeAyah.
  ///
  /// In tr, this message translates to:
  /// **'İÇERİK TİPİ: AYET'**
  String get contentTypeAyah;

  /// No description provided for @contentTypeQuote.
  ///
  /// In tr, this message translates to:
  /// **'İÇERİK TİPİ: SÖZ'**
  String get contentTypeQuote;

  /// No description provided for @dailyQuote.
  ///
  /// In tr, this message translates to:
  /// **'Günün Sözü'**
  String get dailyQuote;

  /// No description provided for @spiritualPearls.
  ///
  /// In tr, this message translates to:
  /// **'Manevi İnciler'**
  String get spiritualPearls;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In tr, this message translates to:
  /// **'Dil (Uygulama)'**
  String get settingsLanguageSection;

  /// No description provided for @settingsTheme.
  ///
  /// In tr, this message translates to:
  /// **'TEMA'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get settingsThemeDark;

  /// No description provided for @settingsTextSize.
  ///
  /// In tr, this message translates to:
  /// **'METİN BOYUTU'**
  String get settingsTextSize;

  /// No description provided for @settingsProfile.
  ///
  /// In tr, this message translates to:
  /// **'Bilgilerim'**
  String get settingsProfile;

  /// No description provided for @settingsLocation.
  ///
  /// In tr, this message translates to:
  /// **'Konum'**
  String get settingsLocation;

  /// No description provided for @settingsNotification.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim Zamanı'**
  String get settingsNotification;

  /// No description provided for @settingsNotificationAtTime.
  ///
  /// In tr, this message translates to:
  /// **'Vaktinde'**
  String get settingsNotificationAtTime;

  /// No description provided for @settingsDailyContent.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get settingsDailyContent;

  /// No description provided for @settingsShareFormat.
  ///
  /// In tr, this message translates to:
  /// **'PAYLAŞIM FORMATI'**
  String get settingsShareFormat;

  /// No description provided for @settingsShareFormatImage.
  ///
  /// In tr, this message translates to:
  /// **'Görsel'**
  String get settingsShareFormatImage;

  /// No description provided for @settingsShareFormatText.
  ///
  /// In tr, this message translates to:
  /// **'Metin'**
  String get settingsShareFormatText;

  /// No description provided for @settingsBgTheme.
  ///
  /// In tr, this message translates to:
  /// **'Arka Plan Teması'**
  String get settingsBgTheme;

  /// No description provided for @settingsAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get settingsTerms;

  /// No description provided for @settingsDeveloper.
  ///
  /// In tr, this message translates to:
  /// **'Geliştirici Hakkında'**
  String get settingsDeveloper;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @saved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get saved;

  /// No description provided for @sharing.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılıyor...'**
  String get sharing;

  /// No description provided for @zikirmatik.
  ///
  /// In tr, this message translates to:
  /// **'Zikirmatik'**
  String get zikirmatik;

  /// No description provided for @zikirmatikSub.
  ///
  /// In tr, this message translates to:
  /// **'Zikir sayacını kolayca takip edin.'**
  String get zikirmatikSub;

  /// No description provided for @reset.
  ///
  /// In tr, this message translates to:
  /// **'SIFIRLA'**
  String get reset;

  /// No description provided for @goalProgress.
  ///
  /// In tr, this message translates to:
  /// **'HEDEF İLERLEME'**
  String get goalProgress;

  /// No description provided for @zikrSaved.
  ///
  /// In tr, this message translates to:
  /// **'Zikir kaydedildi!'**
  String get zikrSaved;

  /// No description provided for @qiblaFinder.
  ///
  /// In tr, this message translates to:
  /// **'Kıble Bulucu'**
  String get qiblaFinder;

  /// No description provided for @contentLoadError.
  ///
  /// In tr, this message translates to:
  /// **'İçerik yüklenemedi.'**
  String get contentLoadError;

  /// No description provided for @chatTitle.
  ///
  /// In tr, this message translates to:
  /// **'Manevi Rehber Sohbet'**
  String get chatTitle;

  /// No description provided for @chatSub.
  ///
  /// In tr, this message translates to:
  /// **'Dini sorularınızı yapay zeka ile keşfedin.'**
  String get chatSub;

  /// No description provided for @startChat.
  ///
  /// In tr, this message translates to:
  /// **'Sohbete Başla'**
  String get startChat;

  /// No description provided for @loginWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Ruhsal yolculuğunuza devam edin.'**
  String get loginWelcome;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-POSTA'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In tr, this message translates to:
  /// **'örnek@mail.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'ŞİFRE'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginButton;

  /// No description provided for @loggingIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yapılıyor...'**
  String get loggingIn;

  /// No description provided for @or.
  ///
  /// In tr, this message translates to:
  /// **'VEYA'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile devam et'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get registerNow;

  /// No description provided for @serenity.
  ///
  /// In tr, this message translates to:
  /// **'Huzur'**
  String get serenity;

  /// No description provided for @faith.
  ///
  /// In tr, this message translates to:
  /// **'İnanç'**
  String get faith;

  /// No description provided for @belief.
  ///
  /// In tr, this message translates to:
  /// **'İman'**
  String get belief;

  /// No description provided for @registerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerTitle;

  /// No description provided for @registerWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Yeni bir yolculuğa başlayın.'**
  String get registerWelcome;

  /// No description provided for @fullName.
  ///
  /// In tr, this message translates to:
  /// **'AD SOYAD'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get fullNameHint;

  /// No description provided for @registerButton.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerButton;

  /// No description provided for @registering.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get registering;

  /// No description provided for @hasAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get hasAccount;

  /// No description provided for @loginNow.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get loginNow;

  /// No description provided for @registerSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarılı! Giriş yapabilirsiniz.'**
  String get registerSuccess;

  /// No description provided for @registerFail.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarısız'**
  String get registerFail;

  /// No description provided for @loginFail.
  ///
  /// In tr, this message translates to:
  /// **'Giriş başarısız'**
  String get loginFail;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'DİL'**
  String get language;

  /// No description provided for @quranHeader.
  ///
  /// In tr, this message translates to:
  /// **'Kur’an-ı Kerim'**
  String get quranHeader;

  /// No description provided for @searchSurah.
  ///
  /// In tr, this message translates to:
  /// **'Sure ara...'**
  String get searchSurah;

  /// No description provided for @ayahCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Ayet'**
  String ayahCount(int count);

  /// No description provided for @detail.
  ///
  /// In tr, this message translates to:
  /// **'Detay'**
  String get detail;

  /// No description provided for @surahNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Sure bulunamadı.'**
  String get surahNotFound;

  /// No description provided for @lastRead.
  ///
  /// In tr, this message translates to:
  /// **'KALDIĞIN YER'**
  String get lastRead;

  /// No description provided for @surah.
  ///
  /// In tr, this message translates to:
  /// **'Suresi'**
  String get surah;

  /// No description provided for @ayah.
  ///
  /// In tr, this message translates to:
  /// **'Ayet'**
  String get ayah;

  /// No description provided for @surahDetail.
  ///
  /// In tr, this message translates to:
  /// **'Sure Detay'**
  String get surahDetail;

  /// No description provided for @loadingRecitation.
  ///
  /// In tr, this message translates to:
  /// **'Kıraat yükleniyor...'**
  String get loadingRecitation;

  /// No description provided for @audioNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Ses dosyası bulunamadı.'**
  String get audioNotFound;

  /// No description provided for @translationStarted.
  ///
  /// In tr, this message translates to:
  /// **'Meal başlatıldı'**
  String get translationStarted;

  /// No description provided for @selectReciter.
  ///
  /// In tr, this message translates to:
  /// **'Hoca Seç'**
  String get selectReciter;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @listenRecitation.
  ///
  /// In tr, this message translates to:
  /// **'Kıraat Dinle'**
  String get listenRecitation;

  /// No description provided for @listenTranslation.
  ///
  /// In tr, this message translates to:
  /// **'Meal Dinle'**
  String get listenTranslation;

  /// No description provided for @listenAyah.
  ///
  /// In tr, this message translates to:
  /// **'Ayet Dinle'**
  String get listenAyah;

  /// No description provided for @ayahsNotLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Ayetler yüklenemedi.'**
  String get ayahsNotLoaded;

  /// No description provided for @saving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor...'**
  String get saving;

  /// No description provided for @accAndApp.
  ///
  /// In tr, this message translates to:
  /// **'HESAP & UYGULAMA'**
  String get accAndApp;

  /// No description provided for @customizeExperience.
  ///
  /// In tr, this message translates to:
  /// **'Manevi Rehber Deneyiminizi Kişiselleştirin.'**
  String get customizeExperience;

  /// No description provided for @generalSettings.
  ///
  /// In tr, this message translates to:
  /// **'Genel Ayarlar'**
  String get generalSettings;

  /// No description provided for @textSizeSmall.
  ///
  /// In tr, this message translates to:
  /// **'Küçük'**
  String get textSizeSmall;

  /// No description provided for @textSizeMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get textSizeMedium;

  /// No description provided for @textSizeLarge.
  ///
  /// In tr, this message translates to:
  /// **'Büyük'**
  String get textSizeLarge;

  /// No description provided for @month1.
  ///
  /// In tr, this message translates to:
  /// **'Ocak'**
  String get month1;

  /// No description provided for @month2.
  ///
  /// In tr, this message translates to:
  /// **'Şubat'**
  String get month2;

  /// No description provided for @month3.
  ///
  /// In tr, this message translates to:
  /// **'Mart'**
  String get month3;

  /// No description provided for @month4.
  ///
  /// In tr, this message translates to:
  /// **'Nisan'**
  String get month4;

  /// No description provided for @month5.
  ///
  /// In tr, this message translates to:
  /// **'Mayıs'**
  String get month5;

  /// No description provided for @month6.
  ///
  /// In tr, this message translates to:
  /// **'Haziran'**
  String get month6;

  /// No description provided for @month7.
  ///
  /// In tr, this message translates to:
  /// **'Temmuz'**
  String get month7;

  /// No description provided for @month8.
  ///
  /// In tr, this message translates to:
  /// **'Ağustos'**
  String get month8;

  /// No description provided for @month9.
  ///
  /// In tr, this message translates to:
  /// **'Eylül'**
  String get month9;

  /// No description provided for @month10.
  ///
  /// In tr, this message translates to:
  /// **'Ekim'**
  String get month10;

  /// No description provided for @month11.
  ///
  /// In tr, this message translates to:
  /// **'Kasım'**
  String get month11;

  /// No description provided for @month12.
  ///
  /// In tr, this message translates to:
  /// **'Aralık'**
  String get month12;

  /// No description provided for @month1Short.
  ///
  /// In tr, this message translates to:
  /// **'Oca'**
  String get month1Short;

  /// No description provided for @month2Short.
  ///
  /// In tr, this message translates to:
  /// **'Şub'**
  String get month2Short;

  /// No description provided for @month3Short.
  ///
  /// In tr, this message translates to:
  /// **'Mar'**
  String get month3Short;

  /// No description provided for @month4Short.
  ///
  /// In tr, this message translates to:
  /// **'Nis'**
  String get month4Short;

  /// No description provided for @month5Short.
  ///
  /// In tr, this message translates to:
  /// **'May'**
  String get month5Short;

  /// No description provided for @month6Short.
  ///
  /// In tr, this message translates to:
  /// **'Haz'**
  String get month6Short;

  /// No description provided for @month7Short.
  ///
  /// In tr, this message translates to:
  /// **'Tem'**
  String get month7Short;

  /// No description provided for @month8Short.
  ///
  /// In tr, this message translates to:
  /// **'Ağu'**
  String get month8Short;

  /// No description provided for @month9Short.
  ///
  /// In tr, this message translates to:
  /// **'Eyl'**
  String get month9Short;

  /// No description provided for @month10Short.
  ///
  /// In tr, this message translates to:
  /// **'Eki'**
  String get month10Short;

  /// No description provided for @month11Short.
  ///
  /// In tr, this message translates to:
  /// **'Kas'**
  String get month11Short;

  /// No description provided for @month12Short.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get month12Short;

  /// No description provided for @versionInfo.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon {version}'**
  String versionInfo(String version);

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @subhanallah.
  ///
  /// In tr, this message translates to:
  /// **'Subhanallah'**
  String get subhanallah;

  /// No description provided for @alhamdulillah.
  ///
  /// In tr, this message translates to:
  /// **'Elhamdülillah'**
  String get alhamdulillah;

  /// No description provided for @allahuAkbar.
  ///
  /// In tr, this message translates to:
  /// **'Allahü Ekber'**
  String get allahuAkbar;

  /// No description provided for @laIlaheIllallah.
  ///
  /// In tr, this message translates to:
  /// **'Lâ ilâhe illallah'**
  String get laIlaheIllallah;

  /// No description provided for @estagfirullah.
  ///
  /// In tr, this message translates to:
  /// **'Estağfirullah'**
  String get estagfirullah;

  /// No description provided for @loadingPoints.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loadingPoints;

  /// No description provided for @locationFallback.
  ///
  /// In tr, this message translates to:
  /// **'Maltepe, İstanbul'**
  String get locationFallback;

  /// No description provided for @sharePreview.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım Önizlemesi'**
  String get sharePreview;

  /// No description provided for @selectBackground.
  ///
  /// In tr, this message translates to:
  /// **'Arka Plan Seçin'**
  String get selectBackground;

  /// No description provided for @shareAsImage.
  ///
  /// In tr, this message translates to:
  /// **'Görsel Olarak Paylaş'**
  String get shareAsImage;

  /// No description provided for @contentVerse.
  ///
  /// In tr, this message translates to:
  /// **'Ayet'**
  String get contentVerse;

  /// No description provided for @contentHadith.
  ///
  /// In tr, this message translates to:
  /// **'Hadis'**
  String get contentHadith;

  /// No description provided for @contentQuote.
  ///
  /// In tr, this message translates to:
  /// **'Söz'**
  String get contentQuote;

  /// No description provided for @contentPrayer.
  ///
  /// In tr, this message translates to:
  /// **'Dua'**
  String get contentPrayer;

  /// No description provided for @specialDays.
  ///
  /// In tr, this message translates to:
  /// **'Özel Günler'**
  String get specialDays;

  /// No description provided for @settingsReminder15Min.
  ///
  /// In tr, this message translates to:
  /// **'15 Dakika Önce Hatırlat (Titreşim)'**
  String get settingsReminder15Min;

  /// No description provided for @settingsAthanSound.
  ///
  /// In tr, this message translates to:
  /// **'Ezan Sesi Çalsın'**
  String get settingsAthanSound;

  /// No description provided for @settingsAthanDesc.
  ///
  /// In tr, this message translates to:
  /// **'Namaz vakti geldiğinde ezan sesi ile bildir.'**
  String get settingsAthanDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
