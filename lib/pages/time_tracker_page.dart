import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class TimeTracker extends StatefulWidget {
  final FirebaseUser user;
  final Database db;

  TimeTracker({this.user, this.db});

  @override
  State<StatefulWidget> createState() => _TimeTrackerState();
}

class _TimeTrackerState extends State<TimeTracker> {
  bool _isClockedIn = false;

  void clockButtonPressed() {
    setState(() {
      _isClockedIn = !_isClockedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: buildClockButton(),
      ),
    );
  }

  Widget buildClockButton() {
    return SizedBox(
      width: 150,
      height: 40,
      child: RaisedButton(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: Colors.indigo,
        child: Text(_isClockedIn ? 'Sign out' : 'Sign in',
            style: TextStyle(fontSize: 20.0, color: Colors.grey[200])),
        onPressed: clockButtonPressed,
      ),
    );
  }
}
