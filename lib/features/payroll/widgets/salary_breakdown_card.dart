import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/features/payroll/core/payroll_model.dart';

class SalaryBreakdownCard extends StatelessWidget {
  final SalaryBreakdown breakdown;
  final Payslip? payslip;
  final bool isCompact;
  final bool showHeader;

  const SalaryBreakdownCard({
    super.key,
    required this.breakdown,
    this.payslip,
    this.isCompact = true,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    final grossSalary = payslip?.grossSalary ?? breakdown.grossSalary;
    final calendarDays = payslip?.calendarDays ?? breakdown.calendarDays;
    final dailyRate = payslip?.dailyRate ?? (calendarDays > 0 ? grossSalary / calendarDays : 0.0);
    final lopDays = payslip?.lopDays ?? breakdown.lopDays;
    final lopDeduction = payslip?.lopDeduction ?? breakdown.lopDeduction;

    final otEnabled = payslip?.overtimeEnabled ?? breakdown.overtimeEnabled;
    final otRate = payslip?.overtimeRate ?? breakdown.overtimeRate;
    final otHours = payslip?.overtimeHours ?? breakdown.overtimeHours;
    final otAmount = payslip?.overtimeAmount ?? breakdown.overtimeAmount;

    final netSalary = breakdown.netSalary;

    final presentDays = payslip?.presentDays ?? (calendarDays - lopDays.round()).toDouble();
    final halfDays = payslip?.halfDays ?? 0.0;
    final absentDays = payslip?.absentDays ?? lopDays;
    final paidLeaveDays = payslip?.paidLeaveDays ?? 0.0;
    final holidayDays = payslip?.holidayDays ?? 1.0;
    final weeklyOffDays = payslip?.weeklyOffDays ?? 3.0;

    return Container(
      padding: EdgeInsets.all(isCompact ? 10.0 : 14.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHeader) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF6366F1)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Payslip Breakdown',
                          style: GoogleFonts.poppins(
                            fontSize: isCompact ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Real DB Payroll',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
          ],

          // 1. ATTENDANCE SUMMARY SECTION
          _buildSectionHeader('ATTENDANCE SUMMARY', Icons.calendar_month_outlined, isDark),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatChip('PRESENT DAYS', presentDays.toStringAsFixed(2), isDark),
              _buildStatChip('HALF DAYS', halfDays.toStringAsFixed(2), isDark),
              _buildStatChip('ABSENT DAYS', absentDays.toStringAsFixed(2), isDark),
              _buildStatChip('PAID LEAVE', paidLeaveDays.toStringAsFixed(2), isDark),
              _buildStatChip('HOLIDAYS', holidayDays.toStringAsFixed(2), isDark),
              _buildStatChip('WEEK OFFS', weeklyOffDays.toStringAsFixed(2), isDark),
            ],
          ),

          const SizedBox(height: 14),

          // 2. LOP DEDUCTION DETAILS
          _buildSectionHeader('LOP DEDUCTION DETAILS', Icons.remove_circle_outline, isDark),
          const SizedBox(height: 8),
          _buildDetailRow('Gross Monthly Salary', currencyFormat.format(grossSalary), isDark),
          _buildDetailRow('Calendar Days', '$calendarDays days', isDark),
          _buildDetailRow('Daily Rate', currencyFormat.format(dailyRate), isDark),
          _buildDetailRow('Total LOP Days', '${lopDays.toStringAsFixed(2)} days', isDark),
          _buildDetailRow(
            'LOP Deduction Amount',
            '-${currencyFormat.format(lopDeduction)}',
            isDark,
            valueColor: const Color(0xFFEF4444),
            isBold: true,
          ),

          const SizedBox(height: 14),

          // 3. OVERTIME CALCULATIONS
          _buildSectionHeader('OVERTIME CALCULATIONS', Icons.access_time_outlined, isDark),
          const SizedBox(height: 8),
          _buildDetailRow('Overtime Enabled', otEnabled ? 'Yes' : 'No', isDark),
          _buildDetailRow('Overtime Rate', '₹${otRate.toStringAsFixed(0)}/ hr', isDark),
          _buildDetailRow('Total Overtime Hours', '${otHours.toStringAsFixed(2)} hrs', isDark),
          _buildDetailRow(
            'Overtime Allowance Amount',
            '+${currencyFormat.format(otAmount)}',
            isDark,
            valueColor: const Color(0xFF10B981),
            isBold: true,
          ),

          const SizedBox(height: 14),

          // 4. NET PAYABLE SALARY SUMMARY
          _buildSectionHeader('NET PAYABLE SALARY SUMMARY', Icons.payments_outlined, isDark),
          const SizedBox(height: 8),
          _buildDetailRow('Gross Salary', currencyFormat.format(grossSalary), isDark),
          _buildDetailRow('Deduction (LOP)', '-${currencyFormat.format(lopDeduction)}', isDark, valueColor: const Color(0xFFEF4444)),
          _buildDetailRow('Allowance (OT)', '+${currencyFormat.format(otAmount)}', isDark, valueColor: const Color(0xFF10B981)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NET PAYABLE SALARY',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        numberToWords(netSalary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  currencyFormat.format(netSalary),
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 5. GLOSSARY & ABBREVIATIONS
          _buildSectionHeader('GLOSSARY & ABBREVIATIONS', Icons.help_outline_rounded, isDark),
          const SizedBox(height: 6),
          Text(
            'LOP (Loss of Pay): Deduction applied for unauthorized absences, excessive lates, or unpaid leave. Calculated as: Gross Salary / Calendar Days.',
            style: GoogleFonts.poppins(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'OT (Overtime): Compensation paid for additional hours worked outside regular shifts. Computed as: OT Hours * OT Rate.',
            style: GoogleFonts.poppins(fontSize: 9, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF6366F1)),
        const SizedBox(width: 4),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.grey[300] : const Color(0xFF334155),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: isDark ? Colors.grey[300] : const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? (isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}

// [mod:2026-02-25T14:00:00+05:30]
