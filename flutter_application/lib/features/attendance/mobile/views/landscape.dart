import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../attendance_controller.dart';
import '../../models/attendance_session.dart';
import '../../../../shared/widgets/app_sidebar.dart';

class MobileLandscape extends StatelessWidget {
  const MobileLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AttendanceController>();
    
    // For landscape, we might want side-by-side: Left controls, Right list.
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Row(
                children: [
                  // Left Panel: Controls
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDateHeader(context, controller),
                          const SizedBox(height: 32),
                          if (controller.isSameDay(controller.selectedDate, DateTime.now()))
                            _buildActionButtons(context, controller),
                           if (controller.isSubmitting)
                              const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())
                        ],
                      ),
                    ),
                  ),
                  
                  const VerticalDivider(width: 1),
      
                  // Right Panel: List
                  Expanded(
                    flex: 3,
                    child: controller.isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : controller.sessions.isEmpty
                          ? const Center(child: Text('No records.', style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              getItem: (context, index) => _buildSessionCard(controller.sessions[index]),
                              itemCount: controller.sessions.length,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Duplicating helper widgets for now as they are private in Portrait. 
  // Ideally these should be refactored into shared widgets but I am sticking to the structure.
  
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Row(
                    children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF4B5563)),
                        const SizedBox(width: 8),
                        Text(
                            DateFormat('EEE, MMM d').format(controller.selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151)),
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
                height: 60,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting ? null : () => controller.handleAction(context, 'IN'),
                    icon: const Icon(Icons.arrow_forward, size: 24),
                    label: const Text('Time In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                height: 60,
                child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting ? null : () => controller.handleAction(context, 'OUT'),
                    icon: const Icon(Icons.logout, size: 24),
                    label: const Text('Time Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildSessionCard(AttendanceSession session) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
            children: [
                _buildSessionRow(
                    'TIME IN',
                    session.timeIn,
                    session.timeInImage,
                    session.timeInAddress,
                    const Color(0xFF10B981)
                ),
                const Divider(height: 1),
                 _buildSessionRow(
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

  Widget _buildSessionRow(String label, DateTime? time, String? imagePath, String? address, Color color) {
      if (time == null) {
          return Padding(
              padding: const EdgeInsets.all(16),
               child: Row(children: [
                   Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
                   const SizedBox(width: 12),
                   Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                   const Spacer(),
                   const Text('Active', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
               ]),
          );
      }

      return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  ),
                  const SizedBox(width: 12),
                  
                  // Image
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                           image: imagePath != null ? DecorationImage(
                               image: FileImage(File(imagePath)),
                               fit: BoxFit.cover
                           ) : null
                      ),
                      child: imagePath == null ? const Icon(Icons.person, color: Colors.grey) : null,
                  ),
                  
                   const SizedBox(width: 12),
                   Expanded(
                       child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                               Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                               const SizedBox(height: 4),
                               Text(DateFormat('hh:mm a').format(time), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                               const SizedBox(height: 4),
                               Row(children: [
                                   const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                   const SizedBox(width: 4),
                                   Expanded(child: Text(address ?? 'Unknown', style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                               ]),
                           ],
                       ),
                   )
              ],
          ),
      );
  }
}
