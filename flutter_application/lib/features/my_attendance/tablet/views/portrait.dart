import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../my_attendance_controller.dart';

import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';

class TabletPortrait extends StatelessWidget {
  const TabletPortrait({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MyAttendanceController>();

    return Scaffold(
      // backgroundColor: const Color(0xFFF3F4F6), // Removed
      appBar: const CustomAppBar(),
      drawer: const Drawer(
        width: 280,
        child: AppSidebar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
              // Action Buttons
              Row(
                children: [
                   Expanded(
                    child: _buildActionButton(
                      label: 'Time In',
                      icon: Icons.login,
                      color: const Color(0xFF6366F1),
                      textColor: Colors.white,
                      onTap: controller.handleTimeIn,
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Time Out',
                      icon: Icons.logout,
                      color: const Color(0xFF1E293B),
                      textColor: Colors.white,
                      onTap: controller.handleTimeOut,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // Date Selector
              _buildDateSelector(context, controller),
              const SizedBox(height: 48),

              // Attendance Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.records.length,
                separatorBuilder: (c, i) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                   final record = controller.records[index];
                   return _buildAttendanceCard(
                     context,
                     timeIn: record['timeIn'],
                     inStatus: record['inStatus'],
                     inAddress: record['inAddress'],
                     timeOut: record['timeOut'],
                     outStatus: record['outStatus'],
                     outAddress: record['outAddress'],
                     isComplete: record['isComplete'],
                     avatarUrl: record['avatarUrl']
                   );
                },
              ),
                  ],
                ),
              ),
      ),
    );
  }

  // --- Scaled Helpers ---

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, MyAttendanceController controller) {
     return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 24),
            onPressed: controller.previousDay,
            color: Theme.of(context).iconTheme.color,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 24, color: Theme.of(context).iconTheme.color),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(controller.selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 24),
            onPressed: controller.nextDay,
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      );
  }

  Widget _buildAttendanceCard(
    BuildContext context, {
    required String timeIn,
    required String inStatus,
    required String inAddress,
    String? timeOut,
    String? outStatus,
    String? outAddress,
    required bool isComplete,
    String? avatarUrl
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeSection(context, true, timeIn, inStatus, inAddress, avatarUrl),
            const SizedBox(height: 24),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            const SizedBox(height: 24),
            _buildTimeSection(context, false, timeOut, outStatus, outAddress, avatarUrl),
          ],
        ),
    );
  }

  Widget _buildTimeSection(BuildContext context, bool isIn, String? time, String? status, String? address, String? avatarUrl) {
    if (time == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: Theme.of(context).disabledColor, shape: BoxShape.circle)), // Grey dot
              const SizedBox(width: 12),
              Text(
                'TIME OUT',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).disabledColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               CircleAvatar(
                 radius: 30,
                 backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                 child: Icon(Icons.person, color: Theme.of(context).disabledColor, size: 30),
               ),
               const SizedBox(width: 24),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(
                        '—',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Active Session',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                   ],
                 ),
               )
            ],
          ),
        ],
      );
    }

    Color dotColor = isIn ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(
              isIn ? 'TIME IN' : 'TIME OUT',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             if (avatarUrl != null)
               CircleAvatar(
                 radius: 30,
                 backgroundImage: NetworkImage(avatarUrl),
                 onBackgroundImageError: (_, __) {},
                 child: Icon(Icons.person, color: Theme.of(context).iconTheme.color, size: 30),
               )
             else 
               CircleAvatar(
                 radius: 30,
                 backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                 child: Icon(Icons.person, color: Theme.of(context).iconTheme.color, size: 30),
               ),
             const SizedBox(width: 24),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Row(
                      children: [
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (status != null) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: status.contains('LATE') ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: status.contains('LATE') ? const Color(0xFFEA580C) : const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, size: 24, color: Theme.of(context).textTheme.bodySmall?.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            address ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                 ],
               ),
             ),
          ],
        ),
      ],
    );
  }
}
