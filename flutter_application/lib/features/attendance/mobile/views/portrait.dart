import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../attendance_controller.dart';
import '../../models/attendance_session.dart';

class MobilePortrait extends StatelessWidget {
  const MobilePortrait({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AttendanceController>();
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Date Header
              _buildDateHeader(context, controller),
              
              const SizedBox(height: 32),
              
              // Actions (Only if today)
              if (controller.isSameDay(controller.selectedDate, DateTime.now()))
                _buildActionButtons(context, controller),
              
              const SizedBox(height: 32),
              
              // Timeline
              if (controller.isLoading)
                   const Center(child: CircularProgressIndicator())
              else if (controller.sessions.isEmpty)
                   Padding(padding: const EdgeInsets.all(32), child: Text('No attendance records for this date.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)))
              else
                   ...controller.sessions.map((s) => _buildSessionCard(context, s)),
              
              if (controller.isSubmitting)
                   const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, AttendanceController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: controller.previousDay,
            icon: const Icon(Icons.chevron_left)
        ),
        GestureDetector(
            onTap: () async {
                final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                );
                if (picked != null) {
                    controller.updateDate(picked);
                }
            },
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                    children: [
                        Icon(Icons.calendar_today, size: 18, color: Theme.of(context).iconTheme.color?.withOpacity(0.7) ?? Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                            DateFormat('EEEE, MMM d, y').format(controller.selectedDate),
                            style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                    ],
                ),
            ),
        ),
        IconButton(
            onPressed: controller.nextDay,
            icon: const Icon(Icons.chevron_right)
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AttendanceController controller) {
    return Column(
        children: [
            Container(
                width: double.infinity,
                height: 80, // Slightly smaller for mobile
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting ? null : () => controller.handleAction(context, 'IN'),
                    icon: const Icon(Icons.arrow_forward, size: 24),
                    label: const Text('Time In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                    ),
                ),
            ),
             Container(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting ? null : () => controller.handleAction(context, 'OUT'),
                    icon: const Icon(Icons.logout, size: 24),
                    label: const Text('Time Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                    ),
                ),
            ),
        ],
    );
  }

  Widget _buildSessionCard(BuildContext context, AttendanceSession session) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Column(
            children: [
                _buildSessionRow(
                    context,
                    'TIME IN',
                    session.timeIn,
                    session.timeInImage,
                    session.timeInAddress,
                    const Color(0xFF10B981)
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                 _buildSessionRow(
                    context,
                    'TIME OUT',
                    session.timeOut,
                    session.timeOutImage,
                    session.timeOutAddress,
                    session.timeOut != null ? const Color(0xFFEF4444) : Colors.grey
                ),
            ],
        ),
    );
  }

  Widget _buildSessionRow(BuildContext context, String label, DateTime? time, String? imagePath, String? address, Color color) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor = Theme.of(context).textTheme.bodyMedium?.color;
      final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

      if (time == null) {
          return Padding(
              padding: const EdgeInsets.all(24),
               child: Row(children: [
                   Container(width: 8, height: 8, decoration: BoxDecoration(color: subTextColor?.withOpacity(0.3) ?? Colors.grey[300], shape: BoxShape.circle)),
                   const SizedBox(width: 12),
                   Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: subTextColor)),
                   const Spacer(),
                   Text('Active Session', style: TextStyle(color: subTextColor, fontStyle: FontStyle.italic)),
               ]),
          );
      }

      return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  ),
                  const SizedBox(width: 16),
                  
                  // Image
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                           image: imagePath != null ? DecorationImage(
                               image: FileImage(File(imagePath)),
                               fit: BoxFit.cover
                           ) : null
                      ),
                      child: imagePath == null ? Icon(Icons.person, color: subTextColor) : null,
                  ),
                  
                   const SizedBox(width: 16),
                   Expanded(
                       child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                               Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subTextColor, letterSpacing: 1.2)),
                               const SizedBox(height: 4),
                               Text(DateFormat('hh:mm a').format(time), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                               const SizedBox(height: 4),
                               Row(children: [
                                   Icon(Icons.location_on, size: 14, color: subTextColor),
                                   const SizedBox(width: 4),
                                   Expanded(child: Text(address ?? 'Unknown', style: TextStyle(fontSize: 12, color: subTextColor), overflow: TextOverflow.ellipsis)),
                               ]),
                           ],
                       ),
                   )
              ],
          ),
      );
  }
}
