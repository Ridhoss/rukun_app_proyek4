import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RwBarChart extends StatelessWidget {
  const RwBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,

      child: BarChart(
        BarChartData(
          maxY: 150,

          alignment: BarChartAlignment.spaceAround,

          borderData: FlBorderData(show: false),

          gridData: const FlGridData(show: false),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,

                getTitlesWidget: (value, meta) {
                  final labels = ["RT 01", "RT 02", "RT 03", "RT 04", "RT 05"];

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),

                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: [
            _bar(0, 120),
            _bar(1, 130),
            _bar(2, 125),
            _bar(3, 140),
            _bar(4, 135),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,

      barRods: [
        BarChartRodData(
          toY: y,
          width: 16,

          borderRadius: BorderRadius.circular(4),

          rodStackItems: [
            BarChartRodStackItem(0, 40, Colors.amber),
            BarChartRodStackItem(40, 100, Colors.green),
            BarChartRodStackItem(100, y, Colors.blue),
          ],
        ),
      ],
    );
  }
}
