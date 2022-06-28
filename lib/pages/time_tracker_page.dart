import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/conditional_widget.dart';
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

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'time_tracker');

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
      floatingActionButton: _buildFABs(),
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                AnimatedBuilder(
                  animation: anim,
                  builder: (context, child) {
                    return Container(
                      constraints: BoxConstraints(maxWidth: 640),
                      child: Card(
                        child: Container(
                          height: 96,
                          child: Center(
                            child: Text(
                              _timerStr,
                              style: TextStyle(
                                fontSize: 64,
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
                    calendarFormat: MediaQuery.of(context).size.height >= 750
                        ? CalendarFormat.month
                        : CalendarFormat.twoWeeks,
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
                        color: colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: colorScheme.onPrimary,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
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
                              trailing: _selectedTimecard!.requestPending
                                  ? Text(
                                      'Request Pending',
                                      style:
                                          TextStyle(color: colorScheme.error),
                                    )
                                  : IconButton(
                                      icon: Icon(Icons.error_outline),
                                      onPressed: _showTimeRequestDialog,
                                    ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 46,
                      height: 46,
                      child: CircularProgressIndicator(
                        value: min(_totalHours, 60) / 60,
                        backgroundColor: colorScheme.surfaceVariant,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '${_totalHours.toStringAsFixed(1)} hours',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFABs() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          child: const Icon(Icons.add_alert),
          backgroundColor: colorScheme.tertiaryContainer,
          foregroundColor: colorScheme.onTertiaryContainer,
          onPressed: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(
                  DateTime.now().add(Duration(minutes: 1))),
              helpText:
                  'Set Clock ${_clockInTime == null ? 'In' : 'Out'} Reminder',
            );
          },
        ),
        SizedBox(width: 8),
        FloatingActionButton.extended(
          backgroundColor: _clockInTime == null
              ? colorScheme.primaryContainer
              : colorScheme.secondaryContainer,
          foregroundColor: _clockInTime == null
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSecondaryContainer,
          label: SizedBox(
            width: 68,
            child: Center(
              child: ConditionalWidget(
                condition: _clockInTime == null,
                ifTrue: const Text('Clock In'),
                ifFalse: const Text('Clock Out'),
              ),
            ),
          ),
          icon: ConditionalWidget(
            condition: _clockInTime == null,
            ifTrue: const Icon(Icons.timer_outlined),
            ifFalse: const Icon(Icons.timer_off_outlined),
          ),
          onPressed: () {
            DateTime now = DateTime.now();
            String key = '${now.year}-${now.month}-${now.day}';

            if (_clockInTime == null) {
              _timeCards.putIfAbsent(key, () => TimeCard(key, 0, false));
              setState(() {
                _clockInTime = DateTime.now();
                _startTimer();
                _setClockTime();
                _timerColorController.forward();
                _timeCards = _timeCards;
                _selectedTimecard = _getTimecardForDay(_selectedDay);
              });
              Database.clockInUser(widget.user);
            } else {
              int dSeconds = Timestamp.now().seconds -
                  Timestamp.fromDate(_clockInTime!).seconds;
              double hours = dSeconds / 60.0 / 60.0;

              _timeCards.update(
                  key,
                  ((value) => TimeCard(
                      key, value.hours + hours, value.requestPending)));

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
            }
          },
        ),
      ],
    );
  }

  void _showTimeRequestDialog() {
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController controller = TextEditingController();
          ColorScheme colorScheme = Theme.of(context).colorScheme;

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text('Submit Time Request'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onSubmitted: (val) {
                    if (val.length > 0) {
                      Navigator.of(context).pop();
                      _submitTimeRequest(num.parse(controller.text));
                    }
                  },
                  autofocus: true,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: true),
                  keyboardAppearance: colorScheme.brightness,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'(\d*\.?\d*)'))
                  ],
                  controller: controller,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                    labelText: 'Requested Hours',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (controller.text.length > 0) {
                    Navigator.of(context).pop();
                    _submitTimeRequest(num.parse(controller.text));
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        });
  }

  void _submitTimeRequest(num hours) async {
    if (_selectedTimecard != null) {
      List<String> dateVals = _selectedTimecard!.docId.split('-');
      DateTime date = DateTime(int.parse(dateVals[0]), int.parse(dateVals[1]),
          int.parse(dateVals[2]));

      TimeRequest request = TimeRequest(
        uid: widget.user.uid,
        userName: widget.user.displayName ?? 'NULL',
        requestDate: date,
        prevHours: _selectedTimecard!.hours,
        newHours: hours,
      );

      bool submitted = await Database.submitTimeRequest(request);

      _timeCards.update(_selectedTimecard!.docId,
          (value) => TimeCard(value.docId, hours, true));

      setState(() {
        _timeCards = _timeCards;
        _selectedTimecard = _getTimecardForDay(_selectedDay);
      });

      ColorScheme colorScheme = Theme.of(context).colorScheme;

      if (submitted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Time change request submitted.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          backgroundColor: colorScheme.surfaceVariant,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'You already have a pending time request for this day.',
            style: TextStyle(color: colorScheme.error),
          ),
          backgroundColor: colorScheme.surfaceVariant,
        ));
      }
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
