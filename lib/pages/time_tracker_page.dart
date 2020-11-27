import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/services/notifications.dart';
import 'package:rr_attendance/widgets/flutter_speed_dial/flutter_speed_dial.dart';
import 'package:rr_attendance/widgets/wave/config.dart';
import 'package:rr_attendance/widgets/wave/wave.dart';

class TimeTracker extends StatefulWidget {
  final User user;
  final Database db;
  final Notifications notifications;

  TimeTracker({this.user, this.db, this.notifications});

  @override
  State<StatefulWidget> createState() => _TimeTrackerState();
}

class _TimeTrackerState extends State<TimeTracker>
    with SingleTickerProviderStateMixin {
  DateTime _clockInTimeDate;
  String _clockedInTime = '00:00:00';
  bool _isClockedIn = false;
  Timer _clockedInTimer;
  bool _isLoading = true;

  AnimationController _buttonAnimController;
  Animation _buttonColorTween;

  @override
  void initState() {
    super.initState();
    _buttonAnimController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _buttonColorTween = ColorTween(begin: Colors.indigo, end: Colors.grey[850])
        .animate(_buttonAnimController);
    widget.db.getInTimestamp(widget.user).then((value) {
      if (value != null) {
        setState(() {
          _isClockedIn = true;
          _clockInTimeDate = value.toDate();
          setClockedInTime();
          startTimer();
          _isLoading = false;
        });
        _buttonAnimController.forward();
      } else {
        setState(() {
          _isClockedIn = false;
          _clockInTimeDate = null;
          setClockedInTime();
          _isLoading = false;
        });
        _buttonAnimController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopTimer();
    _buttonAnimController.dispose();
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
    widget.notifications.cancelNotifications();
    setState(() {
      _isLoading = true;
    });
    if (_isClockedIn) {
      widget.db.clockOutUser(widget.user).then((hours) {
        setState(() {
          stopTimer();
          _isClockedIn = false;
          _clockInTimeDate = null;
          setClockedInTime();
          _isLoading = false;
        });
        _buttonAnimController.reverse();
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
        _buttonAnimController.forward();
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
    return Scaffold(
      floatingActionButton: buildActionSpeedDial(),
      body: Container(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: FractionalOffset.bottomCenter,
              child: buildBackgroundWave(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: buildTimeTicker(),
                ),
              ],
            ),
            showLoading()
          ],
        ),
      ),
    );
  }

  Widget buildTimeTicker() {
    TextStyle digitStyle = TextStyle(
      fontSize: 86,
      color: Colors.grey[100],
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
    );
    Text separator = Text(':', style: digitStyle);
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_clockedInTime[0], style: digitStyle),
              Text(_clockedInTime[1], style: digitStyle),
              separator,
              Text(_clockedInTime[3], style: digitStyle),
              Text(_clockedInTime[4], style: digitStyle),
              separator,
              Text(_clockedInTime[6], style: digitStyle),
              Text(_clockedInTime[7], style: digitStyle),
            ],
          ),
        ),
      ),
      // color: darkAccent,
    );
  }

  Widget buildActionSpeedDial() {
    return AnimatedBuilder(
      animation: _buttonColorTween,
      builder: (context, child) => SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 36),
        backgroundColor: _buttonColorTween.value,
        overlayColor: Colors.black,
        overlayOpacity: 0,
        buttonSize: 80,
        children: [
          SpeedDialChild(
            child: Icon(
              _isClockedIn ? Icons.timer_off : Icons.timer,
              size: 36,
            ),
            labelWidget: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _isClockedIn ? 'Clock Out' : 'Clock In',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
            backgroundColor: _isClockedIn ? Colors.red[700] : Colors.indigo,
            onTap: clockButtonPressed,
          ),
          SpeedDialChild(
            child: Icon(
              Icons.add_alert,
              size: 36,
            ),
            labelWidget: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _isClockedIn ? 'Clock Out Reminder' : 'Clock In Reminder',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
            backgroundColor: Colors.amber,
            onTap: setNewReminder,
          ),
        ],
      ),
    );
  }

  Future<void> setNewReminder() async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 1))),
      confirmText: 'Confirm',
      cancelText: 'Cancel',
      helpText:
          _isClockedIn ? 'Set Clock Out Reminder' : 'Set Clock In Reminder',
    );
    if (selectedTime != null) {
      DateTime reminderTime = DateTime.now();
      reminderTime = DateTime(reminderTime.year, reminderTime.month,
          reminderTime.day, selectedTime.hour, selectedTime.minute);
      if (reminderTime.isBefore(DateTime.now())) {
        reminderTime = reminderTime.add(Duration(days: 1));
      }
      await widget.notifications.cancelNotifications();
      widget.notifications.scheduleNotification(
          '0',
          _isClockedIn ? 'It\'s time to clock out!' : 'It\'s time to clock in!',
          reminderTime);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          'Reminder scheduled.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.grey[900],
      ));
    }
  }

  Widget buildBackgroundWave() {
    return AnimatedOpacity(
      opacity: _isClockedIn ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Container(
        height: 200,
        width: double.infinity,
        child: WaveWidget(
          backgroundColor: Colors.transparent,
          size: Size(double.infinity, double.infinity),
          waveAmplitude: 5,
          wavePhase: 25,
          waveFrequency: 1.0,
          config: CustomConfig(
            gradients: [
              [Colors.indigo[700], Color(0xee303f9f)],
              [Colors.indigo[600], Color(0x773949ab)],
              [Colors.indigo[500], Color(0x663f51b5)],
              [Colors.indigo[400], Color(0x555c6bc0)],
            ],
            gradientBegin: Alignment.bottomCenter,
            gradientEnd: Alignment.topCenter,
            durations: [35000, 19440, 13800, 10000],
            heightPercentages: [0.10, 0.15, 0.20, 0.25],
          ),
        ),
      ),
    );
  }
}
