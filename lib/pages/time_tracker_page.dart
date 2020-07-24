import 'dart:async';

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
  DateTime _clockInTimeDate;
  String _clockedInTime = '00:00:00';
  bool _isClockedIn = false;
  Timer _clockedInTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.db.getInTimestamp(widget.user).then((value) {
      if (value != null) {
        setState(() {
          _isClockedIn = true;
          _clockInTimeDate = value.toDate();
          setClockedInTime();
          startTimer();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isClockedIn = false;
          _clockInTimeDate = null;
          setClockedInTime();
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopTimer();
  }

  void setClockedInTime() {
    if (_clockInTimeDate != null) {
      Duration delta = DateTime.now().difference(_clockInTimeDate);
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      _clockedInTime =
          '${twoDigits(delta.inHours)}:${twoDigits(delta.inMinutes.remainder(60))}:${twoDigits(delta.inSeconds.remainder(60))}';
    } else {
      _clockedInTime = '00:00:00';
    }
  }

  void startTimer() {
    _clockedInTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        setClockedInTime();
      });
    });
  }

  void stopTimer() {
    if (_clockedInTimer != null) {
      _clockedInTimer.cancel();
      _clockedInTimer = null;
    }
  }

  void clockButtonPressed() {
    setState(() {
      _isLoading = true;
    });
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
          stopTimer();
          _isClockedIn = false;
          _clockInTimeDate = null;
          setClockedInTime();
          _isLoading = false;
        });
      });
    } else {
      widget.db.clockInUser(widget.user).then((value) {
        setState(() {
          _isClockedIn = true;
          _clockInTimeDate = DateTime.now();
          setClockedInTime();
          startTimer();
          _isLoading = false;
        });
      });
    }
  }

  Widget showLoading() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _clockedInTime,
                    style: TextStyle(fontSize: 64),
                  ),
                ),
                buildClockButton()
              ],
            ),
          ),
          showLoading()
        ],
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
