import 'package:flutter/material.dart';
import 'package:rr_attendance/pages/root_page.dart';
import 'package:rr_attendance/services/authentication.dart';
import 'package:rr_attendance/services/database.dart';

void main() {
  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance',
//      theme: ThemeData.dark(),
      theme: ThemeData(
          primarySwatch: Colors.indigo,
          brightness: Brightness.dark,
          accentColor: Colors.indigoAccent),
      home: RootPage(
        auth: Authentication(),
        db: Database(),
      ),
    );
  }
}
