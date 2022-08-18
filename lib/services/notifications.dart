import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifications {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<bool?> init() async {
    await _notifications.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher_foreground'),
        iOS: IOSInitializationSettings(),
      ),
    );

    tz.initializeTimeZones();

    if (Platform.isAndroid) {
      return _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    } else if (Platform.isIOS) {
      return _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    return false;
  }

  static Future scheduleNotification(
      String title, String body, DateTime time) async {
    return _notifications.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(
          time, tz.getLocation(await FlutterNativeTimezone.getLocalTimezone())),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_notifications',
          'reminder',
        ),
        iOS: IOSNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
    );
  }

  static Future cancelScheduledNotifications() {
    return _notifications.cancelAll();
  }
}
