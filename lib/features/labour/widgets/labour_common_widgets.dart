import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillBadge extends StatelessWidget {
  final String skill;

  const SkillBadge({super.key, required this.skill});

  static Color getSkillColor(String skillName) {
    switch (skillName.toLowerCase()) {
      case 'mason':
        return const Color(0xFF818CF8); // Indigo/Blue
      case 'electrician':
        return const Color(0xFF22D3EE); // Cyan
      case 'carpenter':
        return const Color(0xFFFBBF24); // Amber
      case 'plumber':
        return const Color(0xFF60A5FA); // Blue
      case 'welder':
        return const Color(0xFF2DD4BF); // Teal
      case 'painter':
        return const Color(0xFFF472B6); // Pink
      case 'foreman':
      case 'supervisor':
        return const Color(0xFF34D399); // Emerald
      case 'helper':
      default:
        return const Color(0xFF9CA3AF); // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getSkillColor(skill);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        skill.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class SiteStatusBadge extends StatelessWidget {
  final String status;

  const SiteStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? const Color(0xFF10B981) : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceStatusChip extends StatelessWidget {
  final String status;

  const AttendanceStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'present':
        bg = const Color(0xFF065F46);
        fg = const Color(0xFFA7F3D0);
        break;
      case 'absent':
        bg = const Color(0xFF991B1B);
        fg = const Color(0xFFFECACA);
        break;
      case 'half day':
        bg = const Color(0xFF3730A3);
        fg = const Color(0xFFC7D2FE);
        break;
      case 'paid leave':
        bg = const Color(0xFF075985);
        fg = const Color(0xFFBAE6FD);
        break;
      default:
        bg = Colors.grey[800]!;
        fg = Colors.grey[300]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.isEmpty ? 'NOT MARKED' : status.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}

class LabourExcelGrid extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final bool isDark;
  final List<double>? columnWidths;

  const LabourExcelGrid({
    super.key,
    required this.columns,
    required this.rows,
    required this.isDark,
    this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_chart_outlined, size: 44, color: Colors.grey[500]),
            const SizedBox(height: 12),
            Text(
              "No records available in spreadsheet grid",
              style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final headerBg = isDark ? const Color(0xFF151D2A) : const Color(0xFF1E293B);
    final rowBgEven = isDark ? const Color(0xFF0E1420) : Colors.white;
    final rowBgOdd = isDark ? const Color(0xFF141C2B) : const Color(0xFFF8FAFC);
    final gridBorder = isDark ? const Color(0xFF212B3B) : const Color(0xFFE2E8F0);
    final indexBg = isDark ? const Color(0xFF161F2C) : const Color(0xFFF1F5F9);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: gridBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {
                0: const FixedColumnWidth(48), // Index Column #
                if (columnWidths != null)
                  for (int i = 0; i < columnWidths!.length; i++)
                    i + 1: FixedColumnWidth(columnWidths![i]),
              },
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(color: headerBg),
                  children: [
                    // Index Header #
                    TableCell(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: isDark ? const Color(0xFF2A364B) : Colors.white24, width: 1)),
                        ),
                        child: Text(
                          "#",
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                    // Data Column Headers
                    ...columns.map((col) {
                      return TableCell(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(right: BorderSide(color: isDark ? const Color(0xFF2A364B) : Colors.white12, width: 1)),
                          ),
                          child: Text(
                            col.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                // Data Rows
                for (int rowIndex = 0; rowIndex < rows.length; rowIndex++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: rowIndex % 2 == 0 ? rowBgEven : rowBgOdd,
                      border: Border(bottom: BorderSide(color: gridBorder, width: 1)),
                    ),
                    children: [
                      // Index Cell (1, 2, 3...)
                      TableCell(
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                          decoration: BoxDecoration(
                            color: indexBg,
                            border: Border(right: BorderSide(color: gridBorder, width: 1)),
                          ),
                          child: Text(
                            "${rowIndex + 1}",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),

                      // Data Cells
                      ...rows[rowIndex].map((cellWidget) {
                        return TableCell(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: gridBorder, width: 1)),
                            ),
                            child: cellWidget,
                          ),
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
