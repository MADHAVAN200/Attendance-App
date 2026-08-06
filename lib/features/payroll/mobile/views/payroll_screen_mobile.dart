import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../models/payroll_model.dart';
import '../../services/payroll_service.dart';
import '../../services/payslip_pdf_service.dart';
import '../../widgets/pay_period_selector.dart';
import '../../widgets/payroll_metric_badge.dart';
import 'payslip_detail_screen_mobile.dart';
import 'payroll_processing_screen_mobile.dart';

class PayrollScreenMobile extends StatefulWidget {
  const PayrollScreenMobile({super.key});

  @override
  State<PayrollScreenMobile> createState() => _PayrollScreenMobileState();
}

class _PayrollScreenMobileState extends State<PayrollScreenMobile> {
  late PayrollService _payrollService;
  bool _isLoading = true;
  PayrollRun? _payrollRun;
  List<Payslip> _payslips = [];
  String _selectedPeriod = '';
  String _selectedDept = 'All';
  String _searchQuery = '';

  final List<String> _departments = ['All', 'Engineering', 'Product', 'Operations', 'Marketing'];

  @override
  void initState() {
    super.initState();
    _payrollService = PayrollService();
    _selectedPeriod = _payrollService.currentPayPeriod;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final run = await _payrollService.getPayrollRun(payPeriod: _selectedPeriod);
      final list = await _payrollService.getPayslips(
        payPeriod: _selectedPeriod,
        department: _selectedDept,
        searchQuery: _searchQuery,
      );
      setState(() {
        _payrollRun = run;
        _payslips = list;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading payroll mobile data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadData();
  }

  void _openProcessingModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PayrollProcessingScreenMobile(
        payrollService: _payrollService,
        currentPeriod: _selectedPeriod,
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthService>().user;
    final isEmployee = user != null && user.isEmployee;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pay Period Bar
              PayPeriodSelector(
                selectedPeriod: _selectedPeriod,
                availablePeriods: _payrollService.availablePayPeriods,
                onPeriodChanged: _onPeriodChanged,
                status: _payrollRun?.status ?? PayrollStatus.approved,
                onProcessTap: isEmployee ? null : _openProcessingModal,
                isCompact: true,
              ),

              const SizedBox(height: 8),

              // Metrics Row / Grid (Compact 2x2)
              if (_payrollRun != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: PayrollMetricBadge(
                        title: 'Total Net Payout',
                        value: _payrollRun!.formattedTotalNet,
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF6366F1),
                        subtitle: '${_payrollRun!.totalEmployees} Staff Processed',
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: PayrollMetricBadge(
                        title: 'Gross Earnings',
                        value: _payrollRun!.formattedTotalGross,
                        icon: Icons.account_balance_outlined,
                        color: const Color(0xFF10B981),
                        subtitle: 'Before Deductions',
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: PayrollMetricBadge(
                        title: 'Total Deductions',
                        value: _payrollRun!.formattedTotalDeductions,
                        icon: Icons.remove_circle_outline,
                        color: const Color(0xFFEF4444),
                        subtitle: 'PF + ESI + TDS + Leaves',
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: PayrollMetricBadge(
                        title: 'Pay Run Status',
                        value: _payrollRun!.status.label,
                        icon: Icons.verified_outlined,
                        color: const Color(0xFF8B5CF6),
                        subtitle: 'Period Locked',
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 10),

              // Search & Department Filters Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B22) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        onChanged: (val) {
                          _searchQuery = val;
                          _loadData();
                        },
                        style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Search staff by name or code...',
                          hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                          icon: const Icon(Icons.search, size: 16, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Department Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _departments.map((dept) {
                    final isSelected = _selectedDept == dept;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(dept),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedDept = dept);
                            _loadData();
                          }
                        },
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                        ),
                        selectedColor: const Color(0xFF4338CA),
                        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
                        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),

              // Employee Payslips List
              Text(
                'EMPLOYEE SALARY SLIPS (${_payslips.length})',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 6),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_payslips.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'No salary slips found for selected criteria',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _payslips.length,
                  itemBuilder: (context, index) {
                    final slip = _payslips[index];
                    return _buildMobilePayslipCard(context, slip, isDark);
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: isEmployee
          ? null
          : FloatingActionButton.extended(
              onPressed: _openProcessingModal,
              backgroundColor: const Color(0xFF4338CA),
              icon: const Icon(Icons.flash_on, size: 16, color: Colors.white),
              label: Text(
                'Run Payroll',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildMobilePayslipCard(BuildContext context, Payslip slip, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF4338CA).withValues(alpha: 0.15),
                    child: Text(
                      slip.employeeName.isNotEmpty ? slip.employeeName[0] : 'E',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4338CA),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slip.employeeName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${slip.designation} • ${slip.department}',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    slip.formattedNetPay,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Text(
                    'Net Salary',
                    style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Days: ${slip.presentDays}/${slip.totalWorkingDays} | OT: ${slip.overtimeHours}h',
                  style: GoogleFonts.poppins(fontSize: 9, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PayslipDetailScreenMobile(payslip: slip),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'View Slip',
                          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF6366F1)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () async {
                        final path = await PayslipPdfService.generateAndSavePayslipPdf(slip);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("PDF saved: ${path.split('/').last}"),
                              backgroundColor: const Color(0xFF10B981),
                              action: SnackBarAction(
                                label: "OPEN",
                                textColor: Colors.white,
                                onPressed: () => PayslipPdfService.openPayslipPdf(path),
                              ),
                            ),
                          );
                          await PayslipPdfService.openPayslipPdf(path);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, size: 10, color: Color(0xFF10B981)),
                            const SizedBox(width: 2),
                            Text(
                              'PDF',
                              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
