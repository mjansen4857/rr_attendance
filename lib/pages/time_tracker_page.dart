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

  @override
  void initState() {
    super.initState();
    widget.db.getInTimestamp(widget.user).then((value) {
      if (value != null) {
        setState(() {
          _isClockedIn = true;
        });
      } else {
        setState(() {
          _isClockedIn = false;
        });
      }
    });
  }

  void clockButtonPressed() {
    if (_isClockedIn) {
      widget.db.clockOutUser(widget.user).then((hours) {
        final snackbar = SnackBar(
          backgroundColor: Colors.grey[900],
          content: Text(
            'Successfully logged ${hours.toStringAsFixed(1)} hours.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
        setState(() {
          _isClockedIn = false;
        });
      });
    } else {
      widget.db.clockInUser(widget.user).then((value) {
        setState(() {
          _isClockedIn = true;
        });
      });
    }
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
