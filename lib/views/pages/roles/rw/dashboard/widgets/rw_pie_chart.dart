import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RwPieChart extends StatefulWidget {
  const RwPieChart({super.key});

  @override
  State<RwPieChart> createState() => _RwPieChartState();
}

class _RwPieChartState extends State<RwPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sectionsSpace: 2,

          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = response.touchedSection!.touchedSectionIndex;
              });
            },
          ),

          sections: List.generate(5, (i) {
            final colors = [
              Colors.teal,
              Colors.orange,
              Colors.purple,
              Colors.blue,
              Colors.red,
            ];

            final values = <double>[120, 90, 110, 140, 80];
            final titles = ["RT 01", "RT 02", "RT 03", "RT 04", "RT 05"];

            final isTouched = i == touchedIndex;

            return PieChartSectionData(
              value: values[i],
              color: colors[i],
              title: titles[i],
              radius: isTouched ? 60 : 50,
              titleStyle: TextStyle(
                fontSize: isTouched ? 16 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
        ),
      ),
    );
  }
}
