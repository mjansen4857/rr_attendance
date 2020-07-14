import 'package:flutter/material.dart';
import 'package:rr_attendance/color_palette.dart';
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
      theme: ThemeData(primarySwatch: Colors.indigo, canvasColor: darkAccent),
      home: RootPage(
        auth: Authentication(),
      ),
    );
  }
}
