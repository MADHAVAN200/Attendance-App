import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/features/payroll/core/payroll_model.dart';

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
    final currentPeriod = availablePeriods.contains(selectedPeriod)
        ? selectedPeriod
        : (availablePeriods.isNotEmpty ? availablePeriods.first : selectedPeriod);

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
      case PayrollStatus.finalized:
        statusBg = const Color(0xFF6366F1).withValues(alpha: 0.15);
        statusFg = const Color(0xFF6366F1);
        break;
      case PayrollStatus.paid:
        statusBg = const Color(0xFF10B981).withValues(alpha: 0.15);
        statusFg = const Color(0xFF10B981);
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
        vertical: isCompact ? 6 : 8,
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
          // Custom Period Selector Dropdown Trigger
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 10),
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
                  const SizedBox(height: 2),
                  Theme(
                    data: Theme.of(context).copyWith(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: PopupMenuButton<String>(
                      tooltip: 'Select Pay Period',
                      offset: const Offset(0, 34),
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF30363D)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      color: isDark ? const Color(0xFF161B22) : Colors.white,
                      onSelected: (val) => onPeriodChanged(val),
                      itemBuilder: (BuildContext context) {
                        return availablePeriods.map((p) {
                          final isSelected = p == currentPeriod;
                          return PopupMenuItem<String>(
                            value: p,
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6366F1).withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(0xFF6366F1)
                                          : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: Color(0xFF6366F1),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0D1117)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF30363D)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentPeriod,
                              style: GoogleFonts.poppins(
                                fontSize: isCompact ? 12 : 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
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

// [mod:2026-02-25T17:30:00+05:30]

// [upd:2026-05-05T11:30:00+05:30]

// [rev:2026-08-25T13:00:00+05:30]
