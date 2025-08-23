import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> byCategory;
  const ExpensePieChart({super.key, required this.byCategory});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.byCategory.values.fold(0.0, (s, v) => s + v);
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: const Center(
          child: Text(
            'No data',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final List<PieChartSectionData> sections = [];
    final List<Color> colorPalette = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
    ];

    int index = 0;
    widget.byCategory.forEach((category, value) {
      final isTouched = index == touchedIndex;
      final pct = (value / total) * 100;
      final double radius = isTouched ? 35 : 30;

      sections.add(
        PieChartSectionData(
          value: value,
          title: pct >= 10 ? '${pct.toStringAsFixed(0)}%' : '',
          radius: radius,
          color: colorPalette[index % colorPalette.length],
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Expenses',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 1,
                centerSpaceRadius: 30,
                sections: sections,
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildMiniLegend(widget.byCategory, colorPalette, total),
        ],
      ),
    );
  }

  Widget _buildMiniLegend(
      Map<String, double> data, List<Color> colors, double total) {
    int index = 0;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: data.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}