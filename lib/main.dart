import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/login_signup_page.dart';

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance',
      theme: ThemeData(primarySwatch: Colors.indigo, canvasColor: darkAccent),
      home: LoginSignupPage(),
    );
  }
}
