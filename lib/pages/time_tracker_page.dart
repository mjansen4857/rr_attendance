import 'package:flutter/material.dart';

class TimeTracker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TimeTrackerState();
}

class _TimeTrackerState extends State<TimeTracker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Time tracker'),
      ),
    );
  }
}
