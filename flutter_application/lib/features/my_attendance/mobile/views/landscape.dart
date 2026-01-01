import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../my_attendance_controller.dart';
import 'portrait.dart'; // Reuse helper methods if possible but private ones need to be copy-pasted or made public.
// To avoid complexity, I'll duplicate the helpers for now as they are small and contained,
// or I can extract them to a shared widget file later. Duplicate for speed/isolation.

import '../../../../shared/widgets/app_sidebar.dart';

class MobileLandscape extends StatelessWidget {
  const MobileLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MyAttendanceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Row(
          children: [
            const AppSidebar(),
            // Left: Controls
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     _buildDateSelector(context, controller),
                     const SizedBox(height: 32),
                     _buildActionButton(
                        label: 'Time In',
                        icon: Icons.login,
                        color: const Color(0xFF6366F1),
                        textColor: Colors.white,
                        onTap: controller.handleTimeIn,
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        label: 'Time Out',
                        icon: Icons.logout,
                        color: const Color(0xFF1E293B),
                        textColor: Colors.white,
                        onTap: controller.handleTimeOut,
                      ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            // Right: List
            Expanded(
              flex: 6,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
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
            ),
          ],
        ),
      ),
    );
  }

  // --- Duplicate Helpers for Isolation ---

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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
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
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
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
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: controller.previousDay,
            color: const Color(0xFF64748B),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, MMM dd').format(controller.selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: controller.nextDay,
            color: const Color(0xFF64748B),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeSection(true, timeIn, inStatus, inAddress, avatarUrl),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 16),
            _buildTimeSection(false, timeOut, outStatus, outAddress, avatarUrl),
          ],
        ),
    );
  }

  Widget _buildTimeSection(bool isIn, String? time, String? status, String? address, String? avatarUrl) {
    if (time == null) {
      return Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle)), 
            const SizedBox(width: 8),
            Text('Processing...', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
          ],
      );
    }
    // Simplified for landscape list item
    Color dotColor = isIn ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Row(
           children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(isIn ? 'IN' : 'OUT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(width: 12),
              Text(time, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              if (status != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: status.contains('LATE') ? Colors.amber.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(status, style: TextStyle(fontSize: 9, color: status.contains('LATE') ? Colors.amber[800] : Colors.green[800], fontWeight: FontWeight.bold)),
                  )
              ]
           ],
         ),
         const SizedBox(height: 4),
         Row(
           children: [
             const Icon(Icons.location_on, size: 12, color: Colors.grey),
             const SizedBox(width: 4),
             Expanded(child: Text(address ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
           ],
         )
      ],
    );
  }
}
