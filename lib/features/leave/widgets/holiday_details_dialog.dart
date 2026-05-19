import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../holidays/models/holiday_model.dart';

class HolidayDetailsDialog extends StatelessWidget {
  final Holiday holiday;
  final double width;
  final EdgeInsets padding;

  const HolidayDetailsDialog({
    super.key, 
    required this.holiday,
    this.width = 400,
    this.padding = const EdgeInsets.all(24),
  });
  
  static Future<void> showMobile(BuildContext context, {required Holiday holiday}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => HolidayDetailsDialog(
        holiday: holiday,
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
      ),
    );
  }

  static Future<void> showPortrait(BuildContext context, {required Holiday holiday}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => HolidayDetailsDialog(
        holiday: holiday,
        width: 450, // Wider for portrait tablet if needed, or standard
        padding: const EdgeInsets.all(32),
      ),
    );
  }

  static Future<void> showLandscape(BuildContext context, {required Holiday holiday}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => HolidayDetailsDialog(
        holiday: holiday,
        width: 500, // Even wider for landscape
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dt = DateTime.parse(holiday.date);

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
            // Header with Name and Close Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holiday.name,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, yyyy').format(dt),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Details Section
            _buildDetailRow(context, Icons.event, "Date", DateFormat('MMMM dd, yyyy').format(dt)),
            const SizedBox(height: 16),
            _buildDetailRow(context, Icons.category, "Type", "Public Holiday"), 
            const SizedBox(height: 16),
            _buildDetailRow(context, Icons.calendar_today, "Day", DateFormat('EEEE').format(dt)),
            
            const SizedBox(height: 32),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text("Close", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
          ],
        )
      ],
    );
  }
}
