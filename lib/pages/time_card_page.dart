import 'package:flutter/material.dart';

class TimeCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Time card'),
      ),
    );
  }
}
