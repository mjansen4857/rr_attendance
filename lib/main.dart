import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/root_page.dart';
import 'package:rr_attendance/services/authentication.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/services/notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  await analytics.logAppOpen();
  Notifications notifications = Notifications();
  await notifications.initNotifications();
  notifications.requestIOSPermissions();
  tz.initializeTimeZones();
  runApp(AttendanceApp(
    analytics: analytics,
    notifications: notifications,
  ));
}

class AttendanceApp extends StatelessWidget {
  final FirebaseAnalytics analytics;
  final Notifications notifications;

  AttendanceApp({this.analytics, this.notifications});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance',
//      theme: ThemeData.dark(),
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.dark,
        accentColor: Colors.indigoAccent,
      ),
      home: RootPage(
        auth: Authentication(analytics: analytics),
        db: Database(),
        notifications: Notifications(),
      ),
    );
  }
}
