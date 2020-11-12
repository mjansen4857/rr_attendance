import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/wave/config.dart';
import 'package:rr_attendance/widgets/wave/wave.dart';

class TimeTracker extends StatefulWidget {
  final User user;
  final Database db;

  TimeTracker({this.user, this.db});

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
    _buttonColorTween = ColorTween(begin: Colors.indigo, end: Colors.red[700])
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
    return Container(
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: buildClockButton(),
                    )
                  ],
                ),
              ),
            ],
          ),
          showLoading()
        ],
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

  Widget buildClockButton() {
    return AnimatedBuilder(
      animation: _buttonColorTween,
      builder: (context, child) => RawMaterialButton(
        onPressed: clockButtonPressed,
        elevation: 3,
        fillColor: _buttonColorTween.value,
        padding: EdgeInsets.all(12),
        shape: CircleBorder(),
        child: Icon(
          _isClockedIn ? Icons.timer_off : Icons.timer,
          size: 48,
          color: Colors.grey[100],
        ),
      ),
    );
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
