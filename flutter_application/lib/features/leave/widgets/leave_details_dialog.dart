import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';

class LeaveDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> leave;
  final double width;
  final EdgeInsets padding;
  final VoidCallback? onWithdraw;

  const LeaveDetailsDialog({
    super.key, 
    required this.leave,
    this.width = 400,
    this.padding = const EdgeInsets.all(24),
    this.onWithdraw,
  });

  static Future<void> showPortrait(BuildContext context, {required Map<String, dynamic> leave, VoidCallback? onWithdraw}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LeaveDetailsDialog(
        leave: leave,
        width: 450,
        padding: const EdgeInsets.all(32),
        onWithdraw: onWithdraw,
      ),
    );
  }

  static Future<void> showLandscape(BuildContext context, {required Map<String, dynamic> leave, VoidCallback? onWithdraw}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LeaveDetailsDialog(
        leave: leave,
        width: 500,
        padding: const EdgeInsets.all(40),
        onWithdraw: onWithdraw,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Parse Dates
    String dateRange = "N/A";
    if (leave['start_date'] != null && leave['end_date'] != null) {
      try {
        final start = DateTime.parse(leave['start_date']);
        final end = DateTime.parse(leave['end_date']);
        dateRange = "${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}";
      } catch (e) {
        dateRange = "${leave['start_date']} - ${leave['end_date']}";
      }
    }

    String appliedOn = "N/A";
    if (leave['created_at'] != null) {
       try {
         final created = DateTime.parse(leave['created_at']);
         appliedOn = DateFormat('MMMM dd, yyyy • hh:mm a').format(created);
       } catch (e) {
         appliedOn = leave['created_at'];
       }
    }

    Color statusColor = Colors.grey;
    final status = leave['status']?.toString().toLowerCase().trim() ?? '';
    if (status == 'approved') statusColor = const Color(0xFF22C55E);
    if (status == 'rejected') statusColor = const Color(0xFFEF4444);
    if (status == 'pending') statusColor = const Color(0xFFF59E0B);

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: GlassContainer(
        width: width,
        padding: padding,
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave['leave_type'] ?? 'Leave Request',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          leave['status']?.toUpperCase() ?? 'UNKNOWN',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Details Grid
            _buildDetailRow(context, Icons.date_range, "Duration", dateRange),
            const SizedBox(height: 16),
            _buildDetailRow(context, Icons.timer, "Days", "${leave['days'] ?? '1'} Days"),
            const SizedBox(height: 16),
            _buildDetailRow(context, Icons.description, "Reason", leave['reason'] ?? 'No reason provided'),
             const SizedBox(height: 16),
             _buildDetailRow(context, Icons.history, "Applied On", appliedOn),

            const SizedBox(height: 32),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                      ),
                      child: Text("Close", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                if (leave['status'] == 'Pending' && onWithdraw != null) ...[
                   const SizedBox(width: 16),
                   Expanded(
                     child: SizedBox(
                       height: 50,
                       child: ElevatedButton(
                         onPressed: () {
                           Navigator.pop(context); // Close dialog first
                           onWithdraw!();
                         },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.red.withOpacity(0.1),
                           foregroundColor: Colors.red,
                           elevation: 0,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                         child: Text("Withdraw", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                       ),
                     ),
                   ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        )
      ],
    );
  }
}
