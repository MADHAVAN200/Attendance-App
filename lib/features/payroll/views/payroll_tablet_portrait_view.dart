import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/shared/services/auth_service.dart';
import 'package:flutter_application/shared/widgets/toast_helper.dart';
import 'package:flutter_application/features/payroll/core/payroll_model.dart';
import 'package:flutter_application/features/payroll/core/payroll_audit_model.dart';
import 'package:flutter_application/features/payroll/core/payroll_service.dart';
import 'package:flutter_application/features/payroll/core/payslip_pdf_service.dart';
import 'package:flutter_application/features/payroll/widgets/pay_period_selector.dart';
import 'package:flutter_application/features/payroll/widgets/payroll_metric_badge.dart';
import 'package:flutter_application/features/payroll/widgets/salary_breakdown_card.dart';

class PayrollScreenTablet extends StatefulWidget {
  const PayrollScreenTablet({super.key});

  @override
  State<PayrollScreenTablet> createState() => _PayrollScreenTabletState();
}

class _PayrollScreenTabletState extends State<PayrollScreenTablet>
    with SingleTickerProviderStateMixin {
  late PayrollService _payrollService;
  late TabController _tabController;

  // --- Payroll Run State ---
  bool _isLoading = true;
  PayrollRun? _payrollRun;
  List<Payslip> _payslips = [];
  Payslip? _selectedPayslip;
  String _selectedPeriod = '';
  String _selectedDept = 'All';
  String _searchQuery = '';

  // Dynamic departments (from data, not hardcoded)
  List<String> _departments = ['All'];
  final TextEditingController _searchController = TextEditingController();

  // --- Lock state ---
  String? _lockingId;

  // --- Audit Trail State ---
  bool _isLoadingAudit = false;
  List<PayrollAuditLog> _auditLogs = [];

  List<Payslip> get _filteredPayslips {
    return _payslips.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.employeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDept = _selectedDept == 'All' || p.department == _selectedDept;
      return matchesSearch && matchesDept;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    final authService = Provider.of<AuthService>(context, listen: false);
    _payrollService = PayrollService(authService.dio);
    _selectedPeriod = _payrollService.currentPayPeriod;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
    if (_tabController.index == 1 && _auditLogs.isEmpty && !_isLoadingAudit) {
      _loadAuditLogs();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Data Loading
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _payrollService.getPayrollDashboard(payPeriod: _selectedPeriod);
      if (mounted) {
        final depts = <String>{'All'};
        for (final s in result.payslips) {
          if (s.department.isNotEmpty) depts.add(s.department);
        }
        setState(() {
          _payrollRun = result.run;
          _payslips = result.payslips;
          _departments = depts.toList();
          if (result.payslips.isNotEmpty &&
              (_selectedPayslip == null ||
                  !result.payslips.any((p) => p.id == _selectedPayslip!.id))) {
            _selectedPayslip = result.payslips.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading payroll tablet data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAuditLogs() async {
    setState(() => _isLoadingAudit = true);
    try {
      final logs = await _payrollService.getAuditLogs(payPeriod: _selectedPeriod);
      if (mounted) setState(() => _auditLogs = logs);
    } catch (e) {
      debugPrint('Error loading audit logs: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAudit = false);
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      _auditLogs = [];
    });
    _loadData();
    if (_tabController.index == 1) _loadAuditLogs();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PDF Download (extracted to avoid BuildContext async gap lint)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _downloadSelectedPdf() async {
    final slip = _selectedPayslip;
    if (slip == null) return;
    try {
      final path = await PayslipPdfService.generateAndSavePayslipPdf(slip);
      if (!mounted) return;
      context.showToast(
        "PDF saved: ${path.split('/').last}",
        isSuccess: true,
        actionLabel: "OPEN",
        onActionPressed: () => PayslipPdfService.openPayslipPdf(path),
      );
      await PayslipPdfService.openPayslipPdf(path);
    } catch (e) {
      if (!mounted) return;
      context.showExceptionToast(e, fallback: 'Failed to generate PDF');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lock / Unlock
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _toggleLock(Payslip slip, bool isAdmin) async {
    if (!isAdmin) return;
    final isLocked = slip.status.isLocked;
    final isPaid = slip.status == PayrollStatus.paid;
    if (isPaid) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(
                isLocked ? Icons.lock_open_outlined : Icons.lock_outlined,
                color: isLocked ? const Color(0xFFF59E0B) : const Color(0xFF4338CA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isLocked ? 'Unlock Payroll?' : 'Lock & Finalize?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          content: Text(
            isLocked
                ? 'This will revert ${slip.employeeName}\'s payroll to Draft status.'
                : 'This will lock and finalize ${slip.employeeName}\'s payroll for ${slip.payPeriod}.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLocked ? const Color(0xFFF59E0B) : const Color(0xFF4338CA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isLocked ? 'Unlock' : 'Lock',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    setState(() => _lockingId = slip.employeeId);
    try {
      if (isLocked) {
        await _payrollService.unlockEmployee(
          employeeId: slip.employeeId,
          payPeriod: _selectedPeriod,
        );
        if (mounted) {
          context.showToast(
            "${slip.employeeName}'s payroll unlocked.",
            isWarning: true,
          );
        }
      } else {
        await _payrollService.finalizeEmployee(
          employeeId: slip.employeeId,
          payPeriod: _selectedPeriod,
        );
        if (mounted) {
          context.showToast(
            "${slip.employeeName}'s payroll locked & finalized.",
            isSuccess: true,
          );
        }
      }
      await _loadData();
      if (_tabController.index == 1) await _loadAuditLogs();
    } catch (e) {
      if (mounted) {
        context.showExceptionToast(e, fallback: 'Action failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _lockingId = null);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

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
            // Top Bar: Pay Period Selector (no Run Payroll)
            PayPeriodSelector(
              selectedPeriod: _selectedPeriod,
              availablePeriods: _payrollService.availablePayPeriods,
              onPeriodChanged: _onPeriodChanged,
              status: _payrollRun?.status ?? PayrollStatus.draft,
              onProcessTap: null, // Run Payroll removed
              isCompact: true,
            ),

            const SizedBox(height: 10),

            // Metrics Header Banner
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
                      title: 'Gross Payroll',
                      value: _payrollRun!.formattedTotalGross,
                      icon: Icons.account_balance_outlined,
                      color: const Color(0xFF10B981),
                      subtitle: 'Basic + Allowances',
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
                      subtitle: 'LOP Deductions',
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
                      subtitle: _payrollRun!.isLocked ? 'Period Locked' : 'In Progress',
                      isCompact: true,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // ── Full-Page Pill Tab Bar (Matching DAR) ────────────────────
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF30363D) : Colors.grey[300]!,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: isDark ? const Color(0xFF2D3139) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                labelColor: isDark ? Colors.white : const Color(0xFF5B60F6),
                unselectedLabelColor: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    height: 38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long_outlined, size: 16),
                        SizedBox(width: 8),
                        Text("Salary Slips"),
                      ],
                    ),
                  ),
                  Tab(
                    height: 38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history_rounded, size: 16),
                        const SizedBox(width: 8),
                        const Text("Audit Trail"),
                        if (_auditLogs.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B60F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_auditLogs.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab Views ────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPayrollTab(isDark, isEmployee),
                  _buildAuditTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 1: Salary Slips (dual pane)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPayrollTab(bool isDark, bool isEmployee) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Pane: Employee List (42%)
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
                // Search
                Container(
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
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search staff...',
                      hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                      icon: const Icon(Icons.search, size: 14, color: Colors.grey),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Dept Chips (dynamic)
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
                            if (sel) setState(() => _selectedDept = dept);
                          },
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey[300] : Colors.grey[800]),
                          ),
                          selectedColor: const Color(0xFF4338CA),
                          backgroundColor:
                              isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                          visualDensity:
                              const VisualDensity(horizontal: -4, vertical: -4),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
                      : _filteredPayslips.isEmpty
                          ? Center(
                              child: Text(
                                'No staff slips found',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredPayslips.length,
                              itemBuilder: (context, index) {
                                final slip = _filteredPayslips[index];
                                final isSelected = _selectedPayslip?.id == slip.id;
                                final isLocked = slip.status.isLocked;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF4338CA).withValues(
                                            alpha: isDark ? 0.25 : 0.08)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF4338CA)
                                          : (isDark
                                              ? const Color(0xFF21262D)
                                              : const Color(0xFFF1F5F9)),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      dense: true,
                                      visualDensity: const VisualDensity(
                                          vertical: -3, horizontal: -2),
                                      leading: CircleAvatar(
                                        radius: 12,
                                        backgroundColor: const Color(0xFF4338CA)
                                            .withValues(alpha: 0.15),
                                        child: Text(
                                          slip.employeeName.isNotEmpty
                                              ? slip.employeeName[0]
                                              : 'E',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF4338CA),
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              slip.employeeName,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1E293B),
                                              ),
                                            ),
                                          ),
                                          if (isLocked)
                                            const Icon(Icons.lock,
                                                size: 10, color: Color(0xFF4338CA)),
                                        ],
                                      ),
                                      subtitle: Text(
                                        '${slip.designation} • LOP: -Rs.${slip.lopDeduction.toStringAsFixed(0)} (${slip.lopDays.toStringAsFixed(0)} d)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
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
                                      onTap: () =>
                                          setState(() => _selectedPayslip = slip),
                                    ),
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

        // Right Pane: Payslip Detail (58%)
        Expanded(
          flex: 58,
          child: _selectedPayslip == null
              ? Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B22) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Select an employee to view salary slip',
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                )
              : _buildDetailPane(isDark, isEmployee),
        ),
      ],
    );
  }

  Widget _buildDetailPane(bool isDark, bool isEmployee) {
    final slip = _selectedPayslip!;
    final isLocked = slip.status.isLocked;
    final isPaid = slip.status == PayrollStatus.paid;
    final isBeingLocked = _lockingId == slip.employeeId;

    return Container(
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
          // Header row: Name + actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          slip.employeeName,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4338CA).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock,
                                    size: 9, color: Color(0xFF4338CA)),
                                const SizedBox(width: 3),
                                Text(
                                  slip.status.label.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4338CA),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${slip.designation} (${slip.employeeId}) • ${slip.payPeriod}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  // Lock / Unlock button (admin only)
                  if (!isEmployee) ...[
                    _buildTabletLockBtn(slip, isDark, isBeingLocked, isPaid),
                    const SizedBox(width: 8),
                  ],
                  // Download PDF button
                  ElevatedButton.icon(
                    onPressed: _downloadSelectedPdf,
                    icon: const Icon(Icons.picture_as_pdf, size: 14),
                    label: Text(
                      'Download PDF',
                      style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4338CA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Attendance & Bank summary chips
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                _buildTabletMeta('Present Days',
                    '${(slip.presentDays as num).toStringAsFixed(0)}/${slip.totalWorkingDays}',
                    isDark),
                _buildTabletMeta('Unpaid Leaves', '${slip.unpaidLeaves} d', isDark),
                _buildTabletMeta(
                    'Overtime', '${slip.overtimeHours} hrs', isDark),
                _buildTabletMeta('PAN', slip.panNumber, isDark),
                _buildTabletMeta('Bank', slip.bankAccount, isDark),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Detailed Salary Breakdown
          Expanded(
            child: SingleChildScrollView(
              child: SalaryBreakdownCard(
                breakdown: slip.breakdown,
                payslip: slip,
                isCompact: true,
                showHeader: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLockBtn(
      Payslip slip, bool isDark, bool isBeingLocked, bool isPaid) {
    final isLocked = slip.status.isLocked;
    final lockColor =
        isLocked ? const Color(0xFF4338CA) : const Color(0xFFF59E0B);

    return OutlinedButton.icon(
      onPressed:
          (isPaid || isBeingLocked) ? null : () => _toggleLock(slip, true),
      icon: isBeingLocked
          ? SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: lockColor),
            )
          : Icon(
              isLocked ? Icons.lock_open_outlined : Icons.lock_outlined,
              size: 13,
            ),
      label: Text(
        isLocked ? 'Unlock' : 'Lock',
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isPaid ? Colors.grey : lockColor,
        side: BorderSide(color: isPaid ? Colors.grey : lockColor),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 2: Audit Trail
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAuditTab(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Audit header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                const Icon(Icons.history, size: 14, color: Color(0xFF4338CA)),
                const SizedBox(width: 6),
                Text(
                  'Audit Trail — $_selectedPeriod',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _loadAuditLogs,
                  child:
                      const Icon(Icons.refresh, size: 16, color: Color(0xFF4338CA)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoadingAudit
                ? const Center(child: CircularProgressIndicator())
                : _auditLogs.isEmpty
                    ? _buildAuditEmptyState(isDark)
                    : _buildAuditTable(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            'No audit records found',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            'Actions like lock, unlock, adjustments will appear here',
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTable(bool isDark) {
    // Column headers matching web Payroll.jsx audit table
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5), // Timestamp
          1: FlexColumnWidth(1.8), // Action
          2: FlexColumnWidth(2),   // Performed By
          3: FlexColumnWidth(2),   // Employee
          4: FlexColumnWidth(3.5), // Details
        },
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
            ),
            children: ['Timestamp', 'Action', 'Performed By', 'Employee', 'Details']
                .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Text(
                        h.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          letterSpacing: 0.4,
                        ),
                      ),
                    ))
                .toList(),
          ),
          ..._auditLogs.map((log) {
            final colors = _auditActionColor(log.action);
            return TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF21262D)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
              ),
              children: [
                // Timestamp
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: Text(
                    log.formattedTime,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                // Action badge
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      log.action,
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: colors.fg,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                // Performed By
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: Text(
                    log.performedByName,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                // Employee
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: Text(
                    log.employeeName ?? '—',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                // Details
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 10),
                  child: Text(
                    log.details,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTabletMeta(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  ({Color bg, Color fg}) _auditActionColor(String action) {
    switch (action.toUpperCase()) {
      case 'LOCK':
        return (bg: const Color(0xFFE0E7FF), fg: const Color(0xFF4338CA));
      case 'UNLOCK':
        return (bg: const Color(0xFFFEF3C7), fg: const Color(0xFFD97706));
      case 'PAY':
        return (bg: const Color(0xFFD1FAE5), fg: const Color(0xFF059669));
      case 'PACKAGE_CREATE':
      case 'PACKAGE_REVISION_CREATE':
        return (bg: const Color(0xFFEDE9FE), fg: const Color(0xFF7C3AED));
      case 'PACKAGE_UPDATE':
        return (bg: const Color(0xFFFCE7F3), fg: const Color(0xFF9D174D));
      case 'PACKAGE_DELETE':
        return (bg: const Color(0xFFFEE2E2), fg: const Color(0xFFDC2626));
      case 'PACKAGE_ASSIGN':
        return (bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1D4ED8));
      case 'PACKAGE_UNASSIGN':
        return (bg: const Color(0xFFFFEDD5), fg: const Color(0xFFEA580C));
      case 'ADJUSTMENT_UPDATE':
        return (bg: const Color(0xFFE0F2FE), fg: const Color(0xFF0369A1));
      default:
        return (bg: const Color(0xFFF1F5F9), fg: const Color(0xFF475569));
    }
  }
}

// [mod:2026-02-25T14:00:00+05:30]

// [rev:2026-08-25T09:00:00+05:30]
