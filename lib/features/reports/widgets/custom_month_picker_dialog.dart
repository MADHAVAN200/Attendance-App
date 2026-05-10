import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomMonthPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomMonthPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (ctx) => CustomMonthPickerDialog(
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2020),
        lastDate: lastDate ?? DateTime(2030),
      ),
    );
  }

  @override
  State<CustomMonthPickerDialog> createState() => _CustomMonthPickerDialogState();
}

class _CustomMonthPickerDialogState extends State<CustomMonthPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF6366F1);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header with Year Navigation ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SELECT MONTH & YEAR",
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      "${_months[_selectedMonth - 1]} $_selectedYear",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 22),
                      onPressed: _selectedYear > widget.firstDate.year
                          ? () => setState(() => _selectedYear--)
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 22),
                      onPressed: _selectedYear < widget.lastDate.year
                          ? () => setState(() => _selectedYear++)
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Months Grid (3 columns x 4 rows) ─────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
              ),
              itemCount: 12,
              itemBuilder: (context, idx) {
                final monthNum = idx + 1;
                final isSelected = _selectedMonth == monthNum;
                final isCurrentMonth = DateTime.now().year == _selectedYear && DateTime.now().month == monthNum;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedMonth = monthNum);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor
                          : (isCurrentMonth
                              ? primaryColor.withValues(alpha: 0.12)
                              : (isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC))),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : (isCurrentMonth
                                ? primaryColor.withValues(alpha: 0.5)
                                : (isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0))),
                        width: isSelected || isCurrentMonth ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _shortMonths[idx],
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isCurrentMonth
                                  ? primaryColor
                                  : (isDark ? Colors.white70 : const Color(0xFF334155))),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),

            // ── Action Buttons ───────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : const Color(0xFF64748B),
                      side: BorderSide(color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final selected = DateTime(_selectedYear, _selectedMonth, 1);
                      Navigator.pop(context, selected);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: Text("Apply Month", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// commit-marker: 2026-02-25T16:45:00+05:30

// [mod:2026-02-26T14:00:00+05:30]

// [upd:2026-05-10T09:00:00+05:30]
