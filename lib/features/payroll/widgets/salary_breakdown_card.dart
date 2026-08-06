import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/payroll_model.dart';
import 'salary_component_row.dart';

class SalaryBreakdownCard extends StatelessWidget {
  final SalaryBreakdown breakdown;
  final bool isCompact;
  final bool showHeader;

  const SalaryBreakdownCard({
    super.key,
    required this.breakdown,
    this.isCompact = true,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹ ', decimalDigits: 0);

    final earningsList = [
      {'label': 'Basic Salary (50%)', 'amount': breakdown.basic, 'subtitle': 'Statutory base pay'},
      {'label': 'HRA (40% of Basic)', 'amount': breakdown.hra, 'subtitle': 'House Rent Allowance'},
      {'label': 'Special Allowance', 'amount': breakdown.specialAllowance, 'subtitle': 'Flexible benefits'},
      if (breakdown.overtimePay > 0)
        {'label': 'Overtime Pay', 'amount': breakdown.overtimePay, 'subtitle': 'Extra hours calculated'},
    ];

    final deductionsList = [
      {'label': 'Provident Fund (PF)', 'amount': breakdown.pf, 'subtitle': '12% of basic pay'},
      if (breakdown.esi > 0)
        {'label': 'ESI Contribution', 'amount': breakdown.esi, 'subtitle': '0.75% state insurance'},
      if (breakdown.tds > 0)
        {'label': 'Tax Deducted (TDS)', 'amount': breakdown.tds, 'subtitle': 'Income tax withholding'},
      if (breakdown.leaveDeductions > 0)
        {'label': 'Unpaid Leave Penalty', 'amount': breakdown.leaveDeductions, 'subtitle': 'Absence deduction'},
      if (breakdown.salaryAdvance > 0)
        {'label': 'Salary Advance Loan', 'amount': breakdown.salaryAdvance, 'subtitle': 'Advance repayment'},
    ];

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
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 16, color: Color(0xFF6366F1)),
                    const SizedBox(width: 6),
                    Text(
                      'Salary Structure Breakdown',
                      style: GoogleFonts.poppins(
                        fontSize: isCompact ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Indian Tax Rules',
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
            const SizedBox(height: 8),
          ],

          // Dual Column / Stacked Layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Earnings Column
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isCompact ? 8 : 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward_rounded, size: 12, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            'EARNINGS',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...earningsList.map((item) => SalaryComponentRow(
                            label: item['label'] as String,
                            amount: item['amount'] as double,
                            subtitle: item['subtitle'] as String?,
                            isCompact: isCompact,
                          )),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(height: 1),
                      ),
                      SalaryComponentRow(
                        label: 'Total Gross Earnings',
                        amount: breakdown.totalEarnings,
                        isBold: true,
                        isCompact: isCompact,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Deductions Column
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(isCompact ? 8 : 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward_rounded, size: 12, color: Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Text(
                            'DEDUCTIONS',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEF4444),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...deductionsList.map((item) => SalaryComponentRow(
                            label: item['label'] as String,
                            amount: item['amount'] as double,
                            subtitle: item['subtitle'] as String?,
                            isDeduction: true,
                            isCompact: isCompact,
                          )),
                      if (deductionsList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No deductions applied',
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(height: 1),
                      ),
                      SalaryComponentRow(
                        label: 'Total Deductions',
                        amount: breakdown.totalDeductions,
                        isDeduction: true,
                        isBold: true,
                        isCompact: isCompact,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Net Payable Footer Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      numberToWords(breakdown.netSalary),
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                Text(
                  currencyFormat.format(breakdown.netSalary),
                  style: GoogleFonts.poppins(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
