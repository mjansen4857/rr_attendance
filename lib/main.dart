import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/login_page.dart';

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  AttendanceApp();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Attendance',
      theme: theme,
      home: LoginPage(),
    );
  }
}
