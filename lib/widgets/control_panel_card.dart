import 'package:flutter/material.dart';

class ControlPanelCard extends StatelessWidget {
  final int? data;
  final String label;

  const ControlPanelCard({
    required this.data,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 150,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (this.data != null)
                  Text(
                    this.data.toString(),
                    style: TextStyle(fontSize: 64),
                  ),
                if (this.data == null)
                  SizedBox(
                    width: 92,
                    height: 92,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                Text(
                  this.label,
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
