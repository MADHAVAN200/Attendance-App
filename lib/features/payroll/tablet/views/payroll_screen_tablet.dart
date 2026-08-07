import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/auth_service.dart';
import '../../models/payroll_model.dart';
import '../../services/payroll_service.dart';
import '../../services/payslip_pdf_service.dart';
import '../../widgets/pay_period_selector.dart';
import '../../widgets/payroll_metric_badge.dart';
import '../../widgets/salary_breakdown_card.dart';
import 'payroll_processing_screen_tablet.dart';

class PayrollScreenTablet extends StatefulWidget {
  const PayrollScreenTablet({super.key});

  @override
  State<PayrollScreenTablet> createState() => _PayrollScreenTabletState();
}

class _PayrollScreenTabletState extends State<PayrollScreenTablet> {
  late PayrollService _payrollService;
  bool _isLoading = true;
  PayrollRun? _payrollRun;
  List<Payslip> _payslips = [];
  Payslip? _selectedPayslip;
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
        if (list.isNotEmpty && (_selectedPayslip == null || !list.any((p) => p.id == _selectedPayslip!.id))) {
          _selectedPayslip = list.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading payroll tablet data: $e");
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
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: PayrollProcessingScreenTablet(
            payrollService: _payrollService,
            currentPeriod: _selectedPeriod,
          ),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Top Bar: Pay Period Selector + Run Payroll Action
            PayPeriodSelector(
              selectedPeriod: _selectedPeriod,
              availablePeriods: _payrollService.availablePayPeriods,
              onPeriodChanged: _onPeriodChanged,
              status: _payrollRun?.status ?? PayrollStatus.approved,
              onProcessTap: isEmployee ? null : _openProcessingModal,
              isCompact: true,
            ),

            const SizedBox(height: 10),

            // Metrics Header Banner (Horizontal Row of 4 Cards)
            if (_payrollRun != null)
              Row(
                children: [
                  Expanded(
                    child: PayrollMetricBadge(
                      title: 'Total Net Payout',
                      value: _payrollRun!.formattedTotalNet,
                      icon: Icons.payments_outlined,
                      color: const Color(0xFF6366F1),
                      subtitle: '${_payrollRun!.totalEmployees} Processed Staff',
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PayrollMetricBadge(
                      title: 'Gross Earnings',
                      value: _payrollRun!.formattedTotalGross,
                      icon: Icons.account_balance_outlined,
                      color: const Color(0xFF10B981),
                      subtitle: 'Base + HRA + Allowances',
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: PayrollMetricBadge(
                      title: 'Status',
                      value: _payrollRun!.status.label,
                      icon: Icons.verified_outlined,
                      color: const Color(0xFF8B5CF6),
                      subtitle: 'Locked Period',
                      isCompact: true,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // Main Dual Pane Body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane: High-Density Employee Register (42% width)
                  Expanded(
                    flex: 42,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B22) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search & Filter Header
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
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
                                      hintText: 'Search staff...',
                                      hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                                      icon: const Icon(Icons.search, size: 14, color: Colors.grey),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Dept Chips Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _departments.map((dept) {
                                final isSelected = _selectedDept == dept;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: ChoiceChip(
                                    label: Text(dept),
                                    selected: isSelected,
                                    onSelected: (sel) {
                                      if (sel) {
                                        setState(() => _selectedDept = dept);
                                        _loadData();
                                      }
                                    },
                                    labelStyle: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                                    ),
                                    selectedColor: const Color(0xFF4338CA),
                                    backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 6),

                          // Employee List
                          Expanded(
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : _payslips.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No staff slips found',
                                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _payslips.length,
                                        itemBuilder: (context, index) {
                                          final slip = _payslips[index];
                                          final isSelected = _selectedPayslip?.id == slip.id;

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 4),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFF4338CA).withValues(alpha: isDark ? 0.25 : 0.08)
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF4338CA)
                                                    : (isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9)),
                                              ),
                                            ),
                                            child: ListTile(
                                              dense: true,
                                              visualDensity: const VisualDensity(vertical: -3, horizontal: -2),
                                              leading: CircleAvatar(
                                                radius: 12,
                                                backgroundColor: const Color(0xFF4338CA).withValues(alpha: 0.15),
                                                child: Text(
                                                  slip.employeeName.isNotEmpty ? slip.employeeName[0] : 'E',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(0xFF4338CA),
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                slip.employeeName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                                ),
                                              ),
                                              subtitle: Text(
                                                '${slip.employeeId} • ${slip.department}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 8,
                                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                ),
                                              ),
                                              trailing: Text(
                                                slip.formattedNetPay,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF10B981),
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() => _selectedPayslip = slip);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Right Pane: Interactive Live Payslip Detail & Preview (58% width)
                  Expanded(
                    flex: 58,
                    child: _selectedPayslip == null
                        ? Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B22) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text('Select an employee to view salary slip', style: GoogleFonts.poppins(color: Colors.grey)),
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161B22) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Selected Employee Header & PDF Button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedPayslip!.employeeName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                                          ),
                                        ),
                                        Text(
                                          '${_selectedPayslip!.designation} (${_selectedPayslip!.employeeId}) • ${_selectedPayslip!.payPeriod}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final path = await PayslipPdfService.generateAndSavePayslipPdf(_selectedPayslip!);
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
                                      icon: const Icon(Icons.picture_as_pdf, size: 14),
                                      label: Text(
                                        'Download PDF Payslip',
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4338CA),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Attendance & Bank Summary Chips
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildTabletMetaItem('Present Days', '${_selectedPayslip!.presentDays}/${_selectedPayslip!.totalWorkingDays}', isDark),
                                      _buildTabletMetaItem('Unpaid Leaves', '${_selectedPayslip!.unpaidLeaves} d', isDark),
                                      _buildTabletMetaItem('Overtime', '${_selectedPayslip!.overtimeHours} hrs', isDark),
                                      _buildTabletMetaItem('PAN', _selectedPayslip!.panNumber, isDark),
                                      _buildTabletMetaItem('Bank', _selectedPayslip!.bankAccount, isDark),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Detailed Salary Breakdown Component
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: SalaryBreakdownCard(
                                      breakdown: _selectedPayslip!.breakdown,
                                      isCompact: true,
                                      showHeader: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletMetaItem(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(fontSize: 7, fontWeight: FontWeight.w700, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E293B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
