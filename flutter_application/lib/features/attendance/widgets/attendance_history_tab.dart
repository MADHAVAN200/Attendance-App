import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'attendance_common_widgets.dart';

class AttendanceHistoryTab extends StatelessWidget {
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AttendanceHistoryTab({
    super.key, 
    this.shrinkWrap = false, 
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.all(24),
      children: [
        // 1. Report Header
        MonthlyReportHeader(
          selectedMonth: DateTime.now(),
          onMonthChanged: (d) {},
        ),
        const SizedBox(height: 32),

        // 2. Week 3 Section (Mock)
        _buildWeekSection(context, 'Week 3', [
           _buildHistoryCard(context, 15, 'Thursday, Jan 15', 'LATE', 'Simulated Office Location', '01:30 PM', '05:02 PM', '-'),
        ]),
        const SizedBox(height: 24),

        // 3. Week 4 Section (Mock)
        _buildWeekSection(context, 'Week 4', [
           _buildHistoryCard(context, 23, 'Friday, Jan 23', 'LATE', 'Simulated Office Location', '09:55 AM', '06:32 PM', '-'),
            _buildHistoryCard(context, 22, 'Thursday, Jan 22', 'LATE', 'Simulated Office Location', '09:50 AM', '07:04 PM', '-'),
             _buildHistoryCard(context, 21, 'Wednesday, Jan 21', 'LATE', 'Simulated Office Location', '09:41 AM', '06:42 PM', '-'),
        ]),
      ],
    );
  }

  Widget _buildWeekSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        const SizedBox(height: 16),
        ...children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, int day, String date, String status, String location, String timeIn, String timeOut, String hrs) {
    final isLate = status == 'LATE';
    final statusColor = isLate ? Colors.orange : Colors.green[100];
    final statusText = isLate ? Colors.orange[800] : Colors.green[800];

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          // Date Box
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF5B60F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$day', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF5B60F6))),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(date, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: statusColor?.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(status, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: statusText)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location, 
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Times
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _buildTimeColumn('IN', timeIn),
                  const SizedBox(width: 16),
                  _buildTimeColumn('OUT', timeOut),
                  const SizedBox(width: 16),
                  _buildTimeColumn('HRS', hrs),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimeColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
