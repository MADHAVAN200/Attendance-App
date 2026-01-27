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
            // Header with Date Badge and Close Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(DateFormat('dd').format(dt), style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                      Text(DateFormat('MMM').format(dt).toUpperCase(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holiday.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
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
                  icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Details Section
            _buildDetailRow(context, Icons.event, "Date", DateFormat('MMMM dd, yyyy').format(dt)),
            const SizedBox(height: 16),
            _buildDetailRow(context, Icons.category, "Type", "Public Holiday"), // Assuming type or static
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
                  backgroundColor: Theme.of(context).primaryColor,
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
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
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
