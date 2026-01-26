import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'attendance_mobile_common_widgets.dart';

class AttendanceHistoryMobile extends StatelessWidget {
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AttendanceHistoryMobile({
    super.key, 
    this.shrinkWrap = false, 
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // 1. Report Header (Mobile)
        MonthlyReportHeaderMobile(
          selectedMonth: DateTime.now(),
          onMonthChanged: (d) {},
        ),
        const SizedBox(height: 32),

        _buildWeekSection(context, 'Week 3', [
           _buildHistoryCard(context, 15, 'Thursday, Jan 15', 'LATE', 'Simulated Office Location', '01:30 PM', '05:02 PM', '-'),
        ]),
        const SizedBox(height: 24),

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
        Text(
          title, 
          style: GoogleFonts.poppins(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7) ?? Colors.grey[600]
          )
        ),
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
      child: Column(
        children: [
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                // Date Box
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B60F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$day', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF5B60F6))),
                ),
                const SizedBox(width: 12),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date, 
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, 
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyLarge?.color
                        )
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location, 
                        style: GoogleFonts.poppins(
                          fontSize: 11, 
                          color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: statusColor?.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(status, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: statusText)),
                      ),
                    ],
                  ),
                ),
             ],
           ),
           const SizedBox(height: 12),
           const Divider(height: 1),
           const SizedBox(height: 12),
           // Times Row (Space Between)
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(context, 'IN', timeIn),
                _buildTimeColumn(context, 'OUT', timeOut),
                _buildTimeColumn(context, 'HRS', hrs),
              ],
           )
        ],
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: GoogleFonts.poppins(
            fontSize: 10, 
            color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey, 
            fontWeight: FontWeight.w600
          )
        ),
        const SizedBox(height: 2),
        Text(
          value, 
          style: GoogleFonts.poppins(
            fontSize: 12, 
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color
          )
        ),
      ],
    );
  }
}
