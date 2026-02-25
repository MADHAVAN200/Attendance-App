import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SalaryComponentRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDeduction;
  final String? subtitle;
  final bool isBold;
  final bool isCompact;

  const SalaryComponentRow({
    super.key,
    required this.label,
    required this.amount,
    this.isDeduction = false,
    this.subtitle,
    this.isBold = false,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹ ', decimalDigits: 0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 3.0 : 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 11 : 13,
                    fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                    color: isDark
                        ? (isBold ? Colors.white : Colors.grey[300])
                        : (isBold ? const Color(0xFF1E293B) : const Color(0xFF475569)),
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${isDeduction && amount > 0 ? "- " : ""}${currencyFormat.format(amount)}',
            style: GoogleFonts.poppins(
              fontSize: isCompact ? 11 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isDeduction
                  ? (amount > 0 ? const Color(0xFFEF4444) : (isDark ? Colors.grey[400] : Colors.grey[600]))
                  : (isDark ? const Color(0xFF34D399) : const Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }
}

// [mod:2026-02-25T17:30:00+05:30]
