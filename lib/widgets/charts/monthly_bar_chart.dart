import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/expense.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<Expense> expenses;
  const MonthlyBarChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expense data available',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Sum per day
    final map = <int, double>{};
    for (final e in expenses) {
      final d = e.date.day;
      map[d] = (map[d] ?? 0) + e.amount;
    }
    
    final maxDay = map.keys.isEmpty ? 30 : map.keys.reduce((a, b) => a > b ? a : b);
    
    // Create bar groups
    final barGroups = List.generate(maxDay, (i) {
      final day = i + 1;
      final amount = map[day] ?? 0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: Theme.of(context).primaryColor,
            width: 6, // Bar width
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    });

    // Calculate max Y value with some padding
    final maxYValue = map.values.isNotEmpty 
      ? (map.values.reduce((a, b) => a > b ? a : b) * 1.1)
      : 100.0;
    final interval = _calculateInterval(maxYValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Monthly Expenses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxYValue,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: _calculateDayInterval(maxDay).toDouble(),
                    getTitlesWidget: (value, meta) {
                      // Only show labels for certain days (5, 10, 15, etc.)
                      if (value % 5 == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '₹${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.15),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final day = group.x;
                    final amount = rod.toY;
                    return BarTooltipItem(
                      'Day $day: ₹${amount.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper function to calculate appropriate interval for days
  int _calculateDayInterval(int maxDay) {
    if (maxDay <= 10) return 2;
    if (maxDay <= 20) return 4;
    if (maxDay <= 30) return 5;
    return 7;
  }

  // Helper function to calculate appropriate Y-axis interval
  double _calculateInterval(double maxValue) {
    if (maxValue <= 50) return 20;
    if (maxValue <= 100) return 30;
    if (maxValue <= 200) return 50;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    return 500;
  }
}