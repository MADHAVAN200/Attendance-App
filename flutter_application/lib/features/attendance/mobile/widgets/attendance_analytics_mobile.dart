import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../widgets/attendance_common_widgets.dart'; // Keep for SummaryCard
import 'attendance_mobile_common_widgets.dart'; // Mobile Header

class AttendanceAnalyticsMobile extends StatelessWidget {
  const AttendanceAnalyticsMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        MonthlyReportHeaderMobile(selectedMonth: DateTime.now(), onMonthChanged: (d){}),
        const SizedBox(height: 24),
        
        // 1. Summary Cards (Stacked for Mobile)
        Column(
          children: [
            AttendanceSummaryCard(title: 'Total Days', value: '10', icon: Icons.calendar_today, color: Colors.blue),
            const SizedBox(height: 12),
            AttendanceSummaryCard(title: 'Present', value: '100%', percentage: '100%'),
            const SizedBox(height: 12),
            AttendanceSummaryCard(title: 'Late', value: '70%', percentage: '70%'),
            const SizedBox(height: 12),
            AttendanceSummaryCard(title: 'Avg Hours', value: '0.0', icon: Icons.access_time, color: Colors.blue),
          ],
        ),
        
        const SizedBox(height: 24),

        // 2. Line Chart
        GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Attendance', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 250, // Slightly shorter for mobile
                child: _LineChartWidget(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 3. Status & Weekly (Stacked)
        _buildAttendanceStatusCard(context),
        const SizedBox(height: 24),
        _buildWeeklyActivityCard(context),
      ],
    );
  }

  Widget _buildAttendanceStatusCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance Status', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(color: const Color(0xFF10B981), value: 3, radius: 20, showTitle: false), 
                            PieChartSectionData(color: const Color(0xFFF59E0B), value: 7, radius: 20, showTitle: false),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('10', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('TOTAL', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(const Color(0xFF10B981), 'On Time'),
                    const SizedBox(height: 12),
                    _buildLegendItem(const Color(0xFFF59E0B), 'Late'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWeeklyActivityCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Activity', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: RadarChart(
              RadarChartData(
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: const BorderSide(color: Colors.transparent),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                tickCount: 1,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                gridBorderData: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
                radarShape: RadarShape.polygon,
                getTitle: (index, angle) {
                  const titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (index < titles.length) return RadarChartTitle(text: titles[index]);
                  return const RadarChartTitle(text: '');
                },
                dataSets: [
                  RadarDataSet(
                    fillColor: const Color(0xFF5B60F6).withValues(alpha: 0.2),
                    borderColor: const Color(0xFF5B60F6),
                    entryRadius: 2,
                    dataEntries: [
                       const RadarEntry(value: 3),
                       const RadarEntry(value: 5),
                       const RadarEntry(value: 2),
                       const RadarEntry(value: 4),
                       const RadarEntry(value: 1),
                       const RadarEntry(value: 0),
                       const RadarEntry(value: 0),
                    ],
                    borderWidth: 2,
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

class _LineChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                  // Simplified for mobile
                  const dates = ['15', '', '19', '', '', '21', '', '23', '', '25']; 
                  if (value.toInt() >= 0 && value.toInt() < dates.length) {
                     return Text(dates[value.toInt()], style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey));
                  }
                  return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 9,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 0.2), FlSpot(1, 0.4), FlSpot(2, 0.3), FlSpot(3, 0.7),
              FlSpot(4, 0.5), FlSpot(5, 0.8), FlSpot(6, 0.6), FlSpot(7, 0.9),
              FlSpot(8, 0.4), FlSpot(9, 0.5),
            ],
            isCurved: true,
            color: const Color(0xFF5B60F6),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF5B60F6).withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}
