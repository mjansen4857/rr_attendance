import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<bool?> init() async {
    await _notifications.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: IOSInitializationSettings(),
      ),
    );

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
}
