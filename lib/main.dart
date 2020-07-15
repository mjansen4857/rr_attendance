import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/root_page.dart';
import 'package:rr_attendance/services/authentication.dart';

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance',
//      theme: ThemeData.dark(),
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.dark),
      home: RootPage(
        auth: Authentication(),
      ),
    );
  }
}
