import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../my_attendance_controller.dart';

class MobilePortrait extends StatelessWidget {
  const MobilePortrait({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MyAttendanceController>();

    return Scaffold(
      // backgroundColor: const Color(0xFFF3F4F6), // Removed to use theme scaffoldBackgroundColor
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 16),
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
              const SizedBox(height: 24),
              
              // Date Selector
              _buildDateSelector(context, controller),
              const SizedBox(height: 24),

              // Attendance Cards
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.records.length,
                separatorBuilder: (c, i) => const SizedBox(height: 16),
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
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
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
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
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: controller.previousDay,
            color: Theme.of(context).iconTheme.color,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Theme.of(context).iconTheme.color),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(controller.selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
              Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).disabledColor, shape: BoxShape.circle)), // Grey dot
              const SizedBox(width: 8),
              Text(
                'TIME OUT',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).disabledColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               CircleAvatar(
                 radius: 20,
                 backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                 child: Icon(Icons.person, color: Theme.of(context).disabledColor),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(
                        '—',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Active Session',
                        style: GoogleFonts.inter(
                          fontSize: 13,
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
            Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              isIn ? 'TIME IN' : 'TIME OUT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             if (avatarUrl != null)
               CircleAvatar(
                 radius: 24,
                 backgroundImage: NetworkImage(avatarUrl),
                 onBackgroundImageError: (_, __) {},
                 child: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
               )
             else 
               CircleAvatar(
                 radius: 24,
                 backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                 child: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
               ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Row(
                      children: [
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (status != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status.contains('LATE') ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: status.contains('LATE') ? const Color(0xFFEA580C) : const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 13,
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
