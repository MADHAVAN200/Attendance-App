import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String total;
  final String percentage;
  final String contextText;
  final bool isPositive;
  final IconData icon;
  final Color baseColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.total,
    required this.percentage,
    required this.contextText,
    required this.isPositive,
    required this.icon,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: baseColor.withOpacity(0.5)),
                  color: baseColor.withOpacity(0.1),
                ),
                child: Icon(icon, color: baseColor, size: 16),
              ),
            ],
          ),
          
          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                total,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subTextColor,
                ),
              ),
            ],
          ),

          // Footer (Trends)
          if (percentage.isNotEmpty)
            Row(
              children: [
                Text(
                  percentage,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  contextText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 16), // Spacer if no trend
        ],
      ),
    );
  }
}
