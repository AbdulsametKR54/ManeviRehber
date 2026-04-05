import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static const int _widgetId = 999;
  static const String _widgetChannelId = 'prayer_widget_channel';

  Future<void> init() async {
    // 1. Initialize Timezones
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 2. Android Settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS Settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 4. Initialization
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      },
    );

    // 5. Request Android 13+ Permissions
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> schedulePrayerNotifications(PrayerTimesModel prayerTimes) async {
    await cancelAll();

    final prefs = await SharedPreferences.getInstance();
    final bool enableReminder = prefs.getBool('enable_prayer_reminder') ?? true;
    final bool enableAthan = prefs.getBool('enable_athan_sound') ?? true;
    final bool enableWidget = prefs.getBool('enable_prayer_widget') ?? false;

    if (!enableReminder && !enableAthan && !enableWidget) return;
    
    if (enableWidget) {
      await showPrayerTimesWidget(prayerTimes);
    }

    final now = DateTime.now();

    // Map of prayer English keys to display names
    final prayers = [
      {'key': 'İmsak', 'id': 1},
      {'key': 'Güneş', 'id': 2},
      {'key': 'Öğle', 'id': 3},
      {'key': 'İkindi', 'id': 4},
      {'key': 'Akşam', 'id': 5},
      {'key': 'Yatsı', 'id': 6},
    ];

    for (var prayer in prayers) {
      final name = prayer['key'] as String;
      final idBase = (prayer['id'] as int) * 10;
      final timeStr = prayerTimes.times[name];

      if (timeStr == null) continue;

      final parts = timeStr.split(':');
      if (parts.length < 2) continue;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      var scheduleDate = DateTime(now.year, now.month, now.day, hour, minute);

      // If time has passed today, schedule for tomorrow
      if (scheduleDate.isBefore(now)) {
        scheduleDate = scheduleDate.add(const Duration(days: 1));
      }

      // 1. Schedule 15-minute reminder
      if (enableReminder) {
        final reminderDate = scheduleDate.subtract(const Duration(minutes: 15));
        if (reminderDate.isAfter(now)) {
          await _scheduleNotification(
            id: idBase + 1,
            title: '$name Vaktine Az Kaldı',
            body: '$name vaktine 15 dakika kaldı.',
            scheduledDate: reminderDate,
            importance: Importance.max,
            priority: Priority.high,
          );
        }
      }

      // 2. Schedule Athan / Vakit notification
      if (enableAthan) {
        await _scheduleNotification(
          id: idBase + 2,
          title: '$name Vakti',
          body: 'Aziz Allah... $name vakti girdi.',
          scheduledDate: scheduleDate,
          sound: 'adhan', // Refers to res/raw/adhan.mp3 on Android
          importance: Importance.max,
          priority: Priority.high,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? sound,
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_notifications_v3', // New channel ID to force settings update
      'Namaz Hatırlatıcıları',
      channelDescription: 'Namaz vakti ve hatırlatıcı bildirimleri (Güçlü Titreşimli)',
      importance: importance == Importance.defaultImportance ? Importance.max : importance,
      priority: priority == Priority.defaultPriority ? Priority.high : priority,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]), // Strong/Long vibration
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  Future<void> showPrayerTimesWidget(PrayerTimesModel times) async {
    final String title = '🕌 ${times.nextPrayer} - Kalan: ${times.countdown}';
    final String timeString = [
      '🕋 İm: ${times.times['İmsak']}',
      '☀️ Gü: ${times.times['Güneş']}',
      '🌤️ Öğ: ${times.times['Öğle']}',
      '🌆 İk: ${times.times['İkindi']}',
      '🌇 Ak: ${times.times['Akşam']}',
      '🌙 Yat: ${times.times['Yatsı']}',
    ].join('  ');

    final String bigText = [
      '🕋 İmsak: ${times.times['İmsak']}    ☀️ Güneş: ${times.times['Güneş']}',
      '🌤️ Öğle: ${times.times['Öğle']}    🌆 İkindi: ${times.times['İkindi']}',
      '🌇 Akşam: ${times.times['Akşam']}    🌙 Yatsı: ${times.times['Yatsı']}',
    ].join('\n');

    final androidDetails = AndroidNotificationDetails(
      _widgetChannelId,
      'Namaz Vakti Widgetı',
      channelDescription: 'Bildirim çekmecesinde sabit namaz vakitleri',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      onlyAlertOnce: true,
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: title,
        summaryText: 'Günlük Namaz Vakitleri',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      _widgetId,
      title,
      timeString,
      notificationDetails,
    );
  }

  Future<void> removePrayerTimesWidget() async {
    await _notificationsPlugin.cancel(_widgetId);
  }

  Future<void> cancelAll() async {
    // We cancel everything. The widget will be recreated in schedulePrayerNotifications 
    // or manually from settings.
    await _notificationsPlugin.cancelAll();
  }
}
