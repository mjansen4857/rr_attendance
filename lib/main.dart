import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/home_page.dart';
import 'package:rr_attendance/services/notifications.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Notifications.init();

  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  AttendanceApp();

  @override
  Widget build(BuildContext context) {
    final ColorScheme defaultLightScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );

    final ColorScheme defaultDarkScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );

    if (Platform.isAndroid) {
      return DynamicColorBuilder(builder: ((lightDynamic, darkDynamic) {
        ColorScheme lightScheme = defaultLightScheme;
        ColorScheme darkScheme = defaultDarkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        }

        return MaterialApp(
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            useMaterial3: true,
          ),
          title: 'Attendance',
          home: HomePage(),
        );
      }));
    } else {
      return MaterialApp(
        title: 'Attendance',
        theme: ThemeData(useMaterial3: true, colorScheme: defaultLightScheme),
        darkTheme:
            ThemeData(useMaterial3: true, colorScheme: defaultDarkScheme),
        home: HomePage(),
      );
    }
  }
}
