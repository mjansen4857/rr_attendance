import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:table_calendar/table_calendar.dart';

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
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<String, TimeCard> _timeCards = {};
  TimeCard? _selectedTimecard;
  double _totalHours = 0;

  @override
  void initState() {
    super.initState();

    _timerColorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

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

    Database.getTimecards(widget.user).then((timecards) {
      for (TimeCard c in timecards) {
        _timeCards.putIfAbsent(c.docId, () => c);
        _totalHours += c.hours;
      }

      setState(() {
        _selectedTimecard = _getTimecardForDay(_selectedDay);
      });
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
          mainAxisSize: MainAxisSize.max,
          children: [
            AnimatedBuilder(
              animation: anim,
              builder: (context, child) {
                return Container(
                  constraints: BoxConstraints(maxWidth: 640),
                  child: Card(
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
                  ),
                );
              },
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 640),
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.utc(2022, 12, 31),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedTimecard = _getTimecardForDay(selectedDay);
                  });
                },
                headerStyle: HeaderStyle(formatButtonVisible: false),
                calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                )),
                rowHeight: 46,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  TimeCard? c = _getTimecardForDay(day);
                  if (c != null) {
                    return [c];
                  } else {
                    return [];
                  }
                },
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _selectedTimecard == null
                    ? Container()
                    : Card(
                        child: ListTile(
                          title: Text(
                              '${_selectedTimecard!.hours.toStringAsFixed(2)} hours'),
                          trailing: IconButton(
                            icon: Icon(Icons.error_outline),
                            onPressed: () {},
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: min(_totalHours, 60) / 60,
                        backgroundColor: colorScheme.surfaceVariant,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${_totalHours.toStringAsFixed(2)} total hours',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
          DateTime now = DateTime.now();
          String key = '${now.year}-${now.month}-${now.day}';

          _timeCards.putIfAbsent(key, () => TimeCard(key, 0));
          setState(() {
            _clockInTime = DateTime.now();
            _startTimer();
            _setClockTime();
            _timerColorController.forward();
            _timeCards = _timeCards;
            _selectedTimecard = _getTimecardForDay(_selectedDay);
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
          int dSeconds = Timestamp.now().seconds -
              Timestamp.fromDate(_clockInTime!).seconds;
          double hours = dSeconds / 60.0 / 60.0;
          DateTime now = DateTime.now();
          String key = '${now.year}-${now.month}-${now.day}';
          _timeCards.update(
              key, ((value) => TimeCard(key, value.hours + hours)));

          setState(() {
            _clockInTime = null;
            _stopTimer();
            _setClockTime();
            _timerColorController.reverse();
            _timeCards = _timeCards;
            _selectedTimecard = _getTimecardForDay(_selectedDay);
            _totalHours += hours;
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

  TimeCard? _getTimecardForDay(DateTime day) {
    String key = '${day.year}-${day.month}-${day.day}';
    if (_timeCards.containsKey(key)) {
      return _timeCards[key];
    }
    return null;
  }
}
