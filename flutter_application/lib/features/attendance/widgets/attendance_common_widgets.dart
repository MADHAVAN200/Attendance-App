import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';

// --- Header ---
class MonthlyReportHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthlyReportHeader({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: const Color(0xFF5B60F6).withOpacity(0.1),
               borderRadius: BorderRadius.circular(12)
             ),
             child: const Icon(Icons.description_outlined, color: Color(0xFF5B60F6)),
           ),
           const SizedBox(width: 16),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text('Monthly Report', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
               Text('Download and view your logs', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
             ],
           ),
           const Spacer(),
           
           // Dropdowns (Simplified for now)
           _buildDropdown(context, DateFormat('MMMM').format(selectedMonth)),
           const SizedBox(width: 8),
           _buildDropdown(context, DateFormat('yyyy').format(selectedMonth)),
           const SizedBox(width: 8),
           
           // Download Button
           ElevatedButton.icon(
             onPressed: () {},
             icon: const Icon(Icons.download, size: 16),
             label: const Text('Download'),
             style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFF5B60F6),
               foregroundColor: Colors.white,
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               textStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(text, style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

// --- Summary Card ---
class AttendanceSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? percentage;

  const AttendanceSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              if (icon != null) Icon(icon, color: color, size: 20),
              if (percentage != null) 
                 Container(
                   padding: const EdgeInsets.all(6),
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     border: Border.all(color: Colors.green),
                   ),
                   child: Text(percentage!, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                 )
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
