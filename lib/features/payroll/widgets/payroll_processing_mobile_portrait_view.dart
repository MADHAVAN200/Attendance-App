import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/shared/widgets/toast_helper.dart';
import 'package:flutter_application/features/payroll/core/payroll_service.dart';

class PayrollProcessingScreenMobile extends StatefulWidget {
  final PayrollService payrollService;
  final String currentPeriod;

  const PayrollProcessingScreenMobile({
    super.key,
    required this.payrollService,
    required this.currentPeriod,
  });

  @override
  State<PayrollProcessingScreenMobile> createState() => _PayrollProcessingScreenMobileState();
}

class _PayrollProcessingScreenMobileState extends State<PayrollProcessingScreenMobile> {
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
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.flash_on, color: Color(0xFF4338CA), size: 20),
              const SizedBox(width: 8),
              Text(
                "Run Payroll Process",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          Text(
            "Pay Period: ${widget.currentPeriod}",
            style: GoogleFonts.poppins(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text("Include Overtime Pay", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                  subtitle: Text("Calculate extra hours at ₹250/hr", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  value: _includeOvertime,
                  onChanged: (val) => setState(() => _includeOvertime = val),
                  activeTrackColor: const Color(0xFF4338CA),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text("Apply Unpaid Leave Deductions", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                  subtitle: Text("Deduct LOP days automatically", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  value: _applyLeaveDeductions,
                  onChanged: (val) => setState(() => _applyLeaveDeductions = val),
                  activeTrackColor: const Color(0xFF4338CA),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text("Lock Period & Auto-Approve", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                  subtitle: Text("Mark status as Disbursed", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                  value: _autoApprove,
                  onChanged: (val) => setState(() => _autoApprove = val),
                  activeTrackColor: const Color(0xFF4338CA),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _runProcessing,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(
                _isProcessing ? "Processing Batch..." : "Execute Pay Period Run",
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4338CA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// [upd:2026-04-26T11:30:00+05:30]

// [upd:2026-05-03T14:00:00+05:30]
