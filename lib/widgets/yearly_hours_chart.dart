import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyHoursChart extends StatefulWidget {
  final num currentHours;

  const YearlyHoursChart({required this.currentHours, super.key});

  @override
  _YearlyHoursChartState createState() => _YearlyHoursChartState();
}

class _YearlyHoursChartState extends State<YearlyHoursChart> {
  List<Color> _gradientColors = [
    Colors.indigo,
    Colors.deepPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: LineChart(_buildData()),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('2022', style: style);
        break;
      case 1:
        text = const Text('2023', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 2:
        text = '2k';
        break;
      case 4:
        text = '4k';
        break;
      case 6:
        text = '6k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData _buildData() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: colorScheme.surfaceVariant,
            getTooltipItems: (List<LineBarSpot> spots) {
              return [
                for (LineBarSpot spot in spots)
                  LineTooltipItem('${(spot.y * 1000).round()}',
                      TextStyle(color: colorScheme.onSurfaceVariant)),
              ];
            }),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          axisNameWidget: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Hours Per Season',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xff68737d),
              ),
            ),
          ),
          axisNameSize: 36,
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 1,
      minY: 0,
      maxY: 8,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 6.219),
            FlSpot(1, widget.currentHours / 1000),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: _gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }
}
