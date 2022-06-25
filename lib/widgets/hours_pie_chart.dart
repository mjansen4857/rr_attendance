import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HoursPieChart extends StatefulWidget {
  final int numUnqual;
  final int numQual;
  final int numAllIn;

  HoursPieChart({
    required this.numUnqual,
    required this.numQual,
    required this.numAllIn,
    super.key,
  });

  @override
  State<HoursPieChart> createState() => _HoursPieChartState();
}

class _HoursPieChartState extends State<HoursPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 180,
        child: Row(
          children: [
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      pieTouchData: PieTouchData(touchCallback:
                          (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 35,
                      sections: _buildSections()),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text('<60'),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 4),
                    Text('60-100'),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(width: 4),
                    Text('100+'),
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 50.0 : 40.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.red,
            value: widget.numUnqual.toDouble(),
            title: '${widget.numUnqual}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: widget.numQual.toDouble(),
            title: '${widget.numQual}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.deepPurple,
            value: widget.numAllIn.toDouble(),
            title: '${widget.numAllIn}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
