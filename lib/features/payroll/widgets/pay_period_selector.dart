import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/payroll_model.dart';

class PayPeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final List<String> availablePeriods;
  final ValueChanged<String> onPeriodChanged;
  final PayrollStatus status;
  final VoidCallback? onProcessTap;
  final bool isCompact;

  const PayPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.availablePeriods,
    required this.onPeriodChanged,
    required this.status,
    this.onProcessTap,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusBg;
    Color statusFg;
    switch (status) {
      case PayrollStatus.draft:
        statusBg = Colors.amber.withValues(alpha: 0.15);
        statusFg = Colors.amber[800]!;
        break;
      case PayrollStatus.processing:
        statusBg = Colors.blue.withValues(alpha: 0.15);
        statusFg = Colors.blue[700]!;
        break;
      case PayrollStatus.approved:
        statusBg = const Color(0xFF10B981).withValues(alpha: 0.15);
        statusFg = const Color(0xFF10B981);
        break;
      case PayrollStatus.disbursed:
        statusBg = const Color(0xFF6366F1).withValues(alpha: 0.15);
        statusFg = const Color(0xFF6366F1);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: isCompact ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Period Selector Dropdown
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF6366F1)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAY PERIOD',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: availablePeriods.contains(selectedPeriod) ? selectedPeriod : availablePeriods.first,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      style: GoogleFonts.poppins(
                        fontSize: isCompact ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                      onChanged: (val) {
                        if (val != null) onPeriodChanged(val);
                      },
                      items: availablePeriods.map((p) {
                        return DropdownMenuItem<String>(
                          value: p,
                          child: Text(p),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Status Badge + Process Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusFg,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status.label.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: statusFg,
                      ),
                    ),
                  ],
                ),
              ),
              if (onProcessTap != null) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onProcessTap,
                  icon: const Icon(Icons.flash_on, size: 14),
                  label: Text(
                    'Run Payroll',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4338CA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
