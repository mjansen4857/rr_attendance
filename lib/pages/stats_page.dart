import 'package:flutter/material.dart';
import 'package:rr_attendance/services/database.dart';
import 'package:rr_attendance/widgets/hours_pie_chart.dart';
import 'package:rr_attendance/widgets/yearly_hours_chart.dart';

class StatsPage extends StatefulWidget {
  StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  num _totalHours = 0;
  num _avgHours = 0;
  int _numUnqual = 0;
  int _numQual = 0;
  int _numAllIn = 0;

  @override
  void initState() {
    super.initState();

    Database.getAllUserDocs().then((value) {
      num sum = 0;
      int unqual = 0;
      int qual = 0;
      int allIn = 0;

      value.forEach((element) {
        if (element.totalHours > 0) {
          sum += element.totalHours;

          if (element.totalHours < 60) {
            unqual++;
          } else if (element.totalHours < 100) {
            qual++;
          } else {
            allIn++;
          }
        }
      });

      setState(() {
        _totalHours = sum;
        _avgHours = sum / value.length;
        _numUnqual = unqual;
        _numQual = qual;
        _numAllIn = allIn;
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
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Container(
                        height: 96,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Total Hours: ${_totalHours.round()}',
                                style: TextStyle(fontSize: 38),
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Average Hours: ${_avgHours.toStringAsFixed(1)}',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              HoursPieChart(
                numUnqual: _numUnqual,
                numQual: _numQual,
                numAllIn: _numAllIn,
              ),
              SizedBox(height: 8),
              YearlyHoursChart(
                currentHours: _totalHours,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
