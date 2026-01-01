import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartSection extends StatelessWidget {
  const ChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Trends',
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Weekly insight',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: const Text('View Details'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 15,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = Text('Mon', style: style); break;
                          case 1: text = Text('Tue', style: style); break;
                          case 2: text = Text('Wed', style: style); break;
                          case 3: text = Text('Thu', style: style); break;
                          case 4: text = Text('Fri', style: style); break;
                          default: text = Text('', style: style);
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 15,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.left,
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 4,
                minY: 0,
                maxY: 60,
                lineBarsData: [
                  // Blue Line (Present)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 52),
                      FlSpot(1, 54),
                      FlSpot(2, 49),
                      FlSpot(3, 53),
                      FlSpot(4, 55),
                    ],
                    isCurved: true,
                    color: const Color(0xFF5B60F6), // Primary Blue
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Orange Line (Late/Absent)
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 5),
                      FlSpot(1, 4),
                      FlSpot(2, 6),
                      FlSpot(3, 4),
                      FlSpot(4, 3),
                    ],
                    isCurved: true,
                    color: const Color(0xFFF59E0B), // Orange
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
