import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../database/database_helper.dart';
import '../data/verses_data.dart';
import 'dart:math';

class NotificationService {
  static const _channelId = 'daily_verse';
  static const _notifId = 0;
  static const _prefEnabled = 'notif_enabled';
  static const _prefHour = 'notif_hour';
  static const _prefMinute = 'notif_minute';

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  // Planifie la notification quotidienne à l'heure choisie avec un verset aléatoire
  static Future<void> scheduleDaily(TimeOfDay time) async {
    await _plugin.cancel(_notifId);

    final verse = await _pickRandomVerse();
    final body = _formatVerseBody(verse.text, verse.reference);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    // Si l'heure est déjà passée aujourd'hui, planifie pour demain
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _notifId,
      '📖 Verset du Jour',
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Verset du Jour',
          channelDescription: 'Notification quotidienne avec un verset biblique',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Répète chaque jour à la même heure
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel() async {
    await _plugin.cancel(_notifId);
  }

  // --- Préférences ---

  static Future<void> savePrefs(
      {required bool enabled, required TimeOfDay time}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, enabled);
    await prefs.setInt(_prefHour, time.hour);
    await prefs.setInt(_prefMinute, time.minute);
  }

  static Future<({bool enabled, TimeOfDay time})> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefEnabled) ?? false;
    final hour = prefs.getInt(_prefHour) ?? 8;
    final minute = prefs.getInt(_prefMinute) ?? 0;
    return (enabled: enabled, time: TimeOfDay(hour: hour, minute: minute));
  }

  // Appelé au démarrage de l'app pour replanifier avec un nouveau verset
  static Future<void> rescheduleIfEnabled() async {
    final prefs = await loadPrefs();
    if (prefs.enabled) {
      await scheduleDaily(prefs.time);
    }
  }

  // --- Helpers ---

  static Future<({String text, String reference})> _pickRandomVerse() async {
    final verses = await DatabaseHelper.instance.getNotionVerses();
    final pool = verses.isNotEmpty ? verses : kPlaceholderVerses;
    final v = pool[Random().nextInt(pool.length)];
    return (text: v.text, reference: v.reference);
  }

  static String _formatVerseBody(String text, String reference) {
    // Tronque le texte si trop long pour la notification
    final truncated =
        text.length > 100 ? '${text.substring(0, 100)}…' : text;
    return '«$truncated» — $reference';
  }
}
