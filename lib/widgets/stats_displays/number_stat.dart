import 'package:flutter/material.dart';

class NumberStat extends StatelessWidget {
  final dynamic data;
  final String label;

  NumberStat(
    this.data,
    this.label,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              data.toString(),
              style: TextStyle(fontSize: 56),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
