import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';

class TimeTrackerPage extends StatefulWidget {
  final User user;

  TimeTrackerPage({
    required this.user,
    super.key,
  });

  @override
  State<TimeTrackerPage> createState() => _TimeTrackerPageState();
}

class _TimeTrackerPageState extends State<TimeTrackerPage>
    with SingleTickerProviderStateMixin {
  String _timerStr = '00:00:00';
  DateTime? _clockInTime;
  Timer? _clockedInTimer;
  late AnimationController _timerColorController;

  @override
  void initState() {
    super.initState();

    _timerColorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    // _timerColorTween = ColorTween()

    Database.getUserInfo(widget.user).then((userInfo) {
      if (userInfo.inTime != null) {
        setState(() {
          _clockInTime = userInfo.inTime!.toDate();
          _setClockTime();
          _startTimer();
          _timerColorController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    var anim = ColorTween(
            begin: colorScheme.surface, end: colorScheme.primaryContainer)
        .animate(_timerColorController);

    return Scaffold(
      floatingActionButton: _buildFAB(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            AnimatedBuilder(
                animation: anim,
                builder: (context, child) {
                  return Card(
                    child: Container(
                      height: 112,
                      child: Center(
                        child: Text(
                          _timerStr,
                          style: TextStyle(
                            fontSize: 78,
                            color: _clockInTime == null
                                ? colorScheme.onSurface
                                : colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    color: anim.value,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(56),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_clockInTime == null) {
      return FloatingActionButton.extended(
        label: Text('Clock In'),
        icon: Icon(Icons.timer_outlined),
        onPressed: () {
          setState(() {
            _clockInTime = DateTime.now();
            _startTimer();
            _setClockTime();
            _timerColorController.forward();
          });
          Database.clockInUser(widget.user);
        },
      );
    } else {
      return FloatingActionButton.extended(
        label: Text('Clock Out'),
        icon: Icon(Icons.timer_off_outlined),
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        onPressed: () {
          setState(() {
            _clockInTime = null;
            _stopTimer();
            _setClockTime();
            _timerColorController.reverse();
          });
          Database.clockOutUser(widget.user);
        },
      );
    }
  }

  void _startTimer() {
    _clockedInTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _setClockTime();
    });
  }

  void _stopTimer() {
    if (_clockedInTimer != null) {
      _clockedInTimer!.cancel();
      _clockedInTimer = null;
    }
  }

  void _setClockTime() {
    if (_clockInTime != null) {
      Duration delta = DateTime.now().difference(_clockInTime!);
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      setState(() {
        _timerStr =
            '${twoDigits(delta.inHours)}:${twoDigits(delta.inMinutes.remainder(60))}:${twoDigits(delta.inSeconds.remainder(60))}';
      });
    } else {
      setState(() {
        _timerStr = '00:00:00';
      });
    }
  }
}
