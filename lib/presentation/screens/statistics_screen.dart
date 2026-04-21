import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:training_app/core/ui_constants.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.padding16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActivityChart(),
            const SizedBox(height: UIConstants.padding24),
            _buildTonnageChart(),
            const SizedBox(height: UIConstants.padding24),
            _buildPersonalRecords(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Активность', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: UIConstants.padding16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 3, color: UIColors.primary)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: UIColors.primary)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2, color: UIColors.primary)]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 4, color: UIColors.primary)]),
                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 6, color: UIColors.primary)]),
                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 1, color: UIColors.primary)]),
                BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 0, color: UIColors.primary)]),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                  const style = TextStyle(color: UIColors.lightGrey, fontSize: 12);
                  String text;
                  switch (value.toInt()) {
                    case 0: text = 'Пн'; break;
                    case 1: text = 'Вт'; break;
                    case 2: text = 'Ср'; break;
                    case 3: text = 'Чт'; break;
                    case 4: text = 'Пт'; break;
                    case 5: text = 'Сб'; break;
                    case 6: text = 'Вс'; break;
                    default: text = ''; break;
                  }
                  return Text(text, style: style);
                }))
              )
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTonnageChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Тоннаж', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: UIConstants.padding16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 1000),
                    const FlSpot(1, 1200),
                    const FlSpot(2, 1100),
                    const FlSpot(3, 1300),
                    const FlSpot(4, 1500),
                  ],
                  isCurved: true,
                  color: UIColors.primary,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: true, color: UIColors.primary.withAlpha((255 * 0.3).round())),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalRecords() {
    // TODO: Implement logic to fetch and display personal records
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Личные рекорды", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: UIConstants.padding16),
        ListTile(
          title: Text("Жим лежа"),
          trailing: Text("100 кг", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: Text("Приседания"),
          trailing: Text("120 кг", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
