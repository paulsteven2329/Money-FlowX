import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_utils.dart';
import '../../domain/entities/transaction.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final Map<String, Color> categoryColors;

  const ExpenseChart({
    super.key,
    required this.categoryData,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final total = categoryData.values.fold(0.0, (a, b) => a + b);
    final sortedData = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _buildSections(sortedData, total),
              centerSpaceRadius: 60,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Handle touch events if needed
                },
                enabled: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(sortedData, total),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(
    List<MapEntry<String, double>> sortedData,
    double total,
  ) {
    return sortedData.take(6).map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = categoryColors[entry.key] ?? Colors.grey;

      return PieChartSectionData(
        value: entry.value,
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        color: color,
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<MapEntry<String, double>> sortedData, double total) {
    return Column(
      children: sortedData.take(6).map((entry) {
        final percentage = (entry.value / total) * 100;
        final color = categoryColors[entry.key] ?? Colors.grey;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(entry.key, style: const TextStyle(fontSize: 14)),
              ),
              Text(
                AppUtils.formatCurrency(entry.value),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SpendingTrendChart extends StatelessWidget {
  final List<FlSpot> data;
  final List<String> labels;

  const SpendingTrendChart({
    super.key,
    required this.data,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    AppUtils.formatCurrency(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Text(
                      labels[index],
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                // ignore: deprecated_member_use
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpendingPieChart extends StatelessWidget {
  final List<dynamic> transactions;
  final List<dynamic> categories;

  const SpendingPieChart({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final categoryExpenses = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryExpenses[transaction.categoryId] =
            (categoryExpenses[transaction.categoryId] ?? 0) +
            transaction.amount;
      }
    }

    if (categoryExpenses.isEmpty) {
      return const Center(child: Text('No expense data to display'));
    }

    final totalExpenses = categoryExpenses.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: sortedCategories.asMap().entries.map((entry) {
                final categoryEntry = entry.value;
                final category = categories.firstWhere(
                  (c) => c.id == categoryEntry.key,
                );
                final percentage = (categoryEntry.value / totalExpenses * 100);

                return PieChartSectionData(
                  color: Color(AppUtils.hexToColor(category.color)),
                  value: percentage,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                enabled: true,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          children: sortedCategories.take(6).map((entry) {
            final category = categories.firstWhere((c) => c.id == entry.key);
            return Container(
              margin: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(AppUtils.hexToColor(category.color)),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(category.name, style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SpendingTrendsChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const SpendingTrendsChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Center(child: Text('No trend data to display'));
    }

    final maxAmount = monthlyData
        .map((data) => [data['income'] as double, data['expenses'] as double])
        .expand((amounts) => amounts)
        .reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxAmount / 5,
          getDrawingHorizontalLine: (value) {
            // ignore: deprecated_member_use
            return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < 0 || value.toInt() >= monthlyData.length) {
                  return Container();
                }
                final month = monthlyData[value.toInt()]['month'] as String;
                final shortMonth = month.split(' ')[0].substring(0, 3);
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(shortMonth, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxAmount / 5,
              reservedSize: 60,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  AppUtils.formatCurrencyShort(value),
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            // ignore: deprecated_member_use
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
            // ignore: deprecated_member_use
            left: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
        ),
        minX: 0,
        maxX: monthlyData.length - 1.0,
        minY: 0,
        maxY: maxAmount * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value['income'] as double,
              );
            }).toList(),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  // ignore: deprecated_member_use
                  Colors.green.withOpacity(0.3),
                  // ignore: deprecated_member_use
                  Colors.green.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: monthlyData.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value['expenses'] as double,
              );
            }).toList(),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.redAccent],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  // ignore: deprecated_member_use
                  Colors.red.withOpacity(0.3),
                  // ignore: deprecated_member_use
                  Colors.red.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final isIncome = barSpot.barIndex == 0;
                return LineTooltipItem(
                  '${isIncome ? 'Income' : 'Expenses'}\n${AppUtils.formatCurrency(flSpot.y)}',
                  TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}
