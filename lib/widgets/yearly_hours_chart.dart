import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyHoursChart extends StatelessWidget {
  final List<FlSpot> yearlyHours;
  final List<Color> _gradientColors = const [
    Colors.indigo,
    Colors.deepPurple,
  ];

  const YearlyHoursChart({required this.yearlyHours, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: this.yearlyHours.length == 0
              ? Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(),
                  ),
                )
              : LineChart(_buildData(context)),
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(
        this
            .yearlyHours[(value - this.yearlyHours.first.x).toInt()]
            .x
            .toInt()
            .toString(),
        style: const TextStyle(
          color: Color(0xff68737d),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 2000:
        text = '2k';
        break;
      case 4000:
        text = '4k';
        break;
      case 6000:
        text = '6k';
        break;
      case 8000:
        text = '8k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData _buildData(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        verticalInterval: 1,
        horizontalInterval: 2000,
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
                  LineTooltipItem('${spot.y}',
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
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2000,
            getTitlesWidget: _leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: this.yearlyHours.first.x,
      maxX: this.yearlyHours.last.x,
      minY: 0,
      maxY: 8000,
      lineBarsData: [
        LineChartBarData(
          spots: this.yearlyHours,
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
