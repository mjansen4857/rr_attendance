import 'package:flutter/material.dart';

class TimeTrackerPage extends StatefulWidget {
  TimeTrackerPage({Key? key}) : super(key: key);

  @override
  State<TimeTrackerPage> createState() => _TimeTrackerPageState();
}

class _TimeTrackerPageState extends State<TimeTrackerPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Time Tracker'),
    );
  }
}
