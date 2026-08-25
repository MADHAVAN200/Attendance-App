import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/shared/widgets/toast_helper.dart';
import 'package:flutter_application/features/payroll/core/payroll_service.dart';

class PayrollProcessingScreenTablet extends StatefulWidget {
  final PayrollService payrollService;
  final String currentPeriod;

  const PayrollProcessingScreenTablet({
    super.key,
    required this.payrollService,
    required this.currentPeriod,
  });

  @override
  State<PayrollProcessingScreenTablet> createState() => _PayrollProcessingScreenTabletState();
}

class _PayrollProcessingScreenTabletState extends State<PayrollProcessingScreenTablet> {
  bool _isProcessing = false;
  bool _includeOvertime = true;
  bool _applyLeaveDeductions = true;
  bool _autoApprove = true;

  Future<void> _runProcessing() async {
    setState(() => _isProcessing = true);
    try {
      await widget.payrollService.processPayrollRun(payPeriod: widget.currentPeriod);
      if (mounted) {
        context.showToast(
          "Payroll run for ${widget.currentPeriod} executed successfully!",
          isSuccess: true,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        context.showExceptionToast(e, fallback: "Payroll processing error");
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, color: Color(0xFF4338CA), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Batch Pay Period Processing",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
          Text(
            "Recalculating monthly salary slips for period: ${widget.currentPeriod}",
            style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  dense: true,
                  title: Text("Include Overtime Hours Pay", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text("Calculates extra hours worked at standard statutory rate", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  value: _includeOvertime,
                  onChanged: (val) => setState(() => _includeOvertime = val),
                  activeTrackColor: const Color(0xFF4338CA),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  dense: true,
                  title: Text("Apply Unpaid Leave Deductions", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text("Deducts daily rate for unapproved absence days", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  value: _applyLeaveDeductions,
                  onChanged: (val) => setState(() => _applyLeaveDeductions = val),
                  activeTrackColor: const Color(0xFF4338CA),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  dense: true,
                  title: Text("Lock Period & Auto-Disburse", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text("Finalize pay run and generate PDF slips for all staff", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  value: _autoApprove,
                  onChanged: (val) => setState(() => _autoApprove = val),
                  activeTrackColor: const Color(0xFF4338CA),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 12)),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _runProcessing,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.flash_on, size: 16),
                label: Text(
                  _isProcessing ? "Processing..." : "Run Batch Payroll",
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4338CA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// [upd:2026-04-26T11:30:00+05:30]

// [rev:2026-08-25T09:00:00+05:30]
