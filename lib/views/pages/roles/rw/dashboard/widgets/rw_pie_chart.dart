import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rw/dashboard/rw_dashboard_viewmodel.dart';

class RwPieChart extends StatefulWidget {
  const RwPieChart({super.key});

  @override
  State<RwPieChart> createState() => _RwPieChartState();
}

class _RwPieChartState extends State<RwPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardRwViewModel>();
    final values = [vm.pria.toDouble(), vm.wanita.toDouble()];
    final titles = ["Pria", "Wanita"];
    final colors = [ColorsUtils.skyblue, ColorsUtils.red];

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
          sections: List.generate(values.length, (i) {
            final isTouched = i == touchedIndex;

            return PieChartSectionData(
              value: values[i],

              color: colors[i],

              title: titles[i],

              radius: isTouched ? 62 : 52,

              titleStyle: TextStyle(
                fontSize: isTouched ? 16 : 12,
                fontWeight: FontWeight.bold,
                color: ColorsUtils.white,
              ),
            );
          }),
        ),
      ),
    );
  }
}
