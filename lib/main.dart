import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/home_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  AttendanceApp();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.light,
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Attendance',
      theme: theme,
      darkTheme: darkTheme,
      home: HomePage(),
    );
  }
}
