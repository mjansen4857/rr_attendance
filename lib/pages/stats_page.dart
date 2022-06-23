import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/total_hours_chart.dart';

class StatsPage extends StatefulWidget {
  StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  num _totalHours = 0;

  @override
  void initState() {
    super.initState();

    Database.getTotalHours().then((value) {
      setState(() {
        _totalHours = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Container(
                        height: 78,
                        child: Center(
                          child: Text(
                            'Total Hours: ${_totalHours.round()}',
                            style: TextStyle(fontSize: 38),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TotalHoursChart(),
            ],
          ),
        ),
      ),
    );
  }
}
