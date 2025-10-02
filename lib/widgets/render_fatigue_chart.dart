import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget renderFatigueChart(List<Map<String, dynamic>> data) {
  final spots = data.asMap().entries.map((entry) {
    final x = entry.key.toDouble(); // index as X
    final yRaw = entry.value['value'];
    final y = yRaw is num ? yRaw.toDouble() : 0.0;
    return FlSpot(x, y);
  }).toList();

  return LineChart(
    LineChartData(
      minX: 0,
      maxX: 2000,
      minY: 0,
      maxY: 5000,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
      ],
    ),
  );
}