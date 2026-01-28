import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';

class MonthlyReportHeaderMobile extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const MonthlyReportHeaderMobile({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
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
            children: [
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: const Color(0xFF5B60F6).withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(12)
                 ),
                 child: const Icon(Icons.description_outlined, color: Color(0xFF5B60F6)),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Monthly Report', 
                       style: GoogleFonts.poppins(
                         fontWeight: FontWeight.bold, 
                         fontSize: 16,
                         color: Theme.of(context).textTheme.bodyLarge?.color,
                       )
                     ),
                     Text(
                       'Download and view your logs', 
                       style: GoogleFonts.poppins(
                         fontSize: 12, 
                         color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                       )
                     ),
                   ],
                 ),
               ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 2: Controls
          Row(
            children: [
               Expanded(child: _buildDropdown(context, DateFormat('MMMM').format(selectedMonth))),
               const SizedBox(width: 8),
               Expanded(child: _buildDropdown(context, DateFormat('yyyy').format(selectedMonth))),
               const SizedBox(width: 8),
               ElevatedButton(
                 onPressed: () {},
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF5B60F6),
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12), // Compact
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   minimumSize: const Size(40, 40), // Ensure touch target
                 ),
                 child: const Icon(Icons.download, size: 20),
               ),
            ],
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
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              text, 
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ), 
              overflow: TextOverflow.ellipsis
            )
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
