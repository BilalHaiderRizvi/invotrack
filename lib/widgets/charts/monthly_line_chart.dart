import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/expense.dart';

class MonthlyLineChart extends StatelessWidget {
  final List<Expense> expenses;
  const MonthlyLineChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) return const Center(child: Text('No data'));

    // Sum per day
    final map = <int, double>{};
    for (final e in expenses) {
      final d = e.date.day;
      map[d] = (map[d] ?? 0) + e.amount;
    }
    final maxDay = map.keys.isEmpty ? 30 : map.keys.reduce((a, b) => a > b ? a : b);
    final spots = List.generate(maxDay, (i) {
      final day = i + 1;
      return FlSpot(day.toDouble(), (map[day] ?? 0));
    });

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: 5)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 50)),
        ),
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3)],
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
