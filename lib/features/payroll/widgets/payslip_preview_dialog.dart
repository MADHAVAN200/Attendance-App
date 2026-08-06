import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/payroll_model.dart';
import '../services/payslip_pdf_service.dart';
import 'salary_breakdown_card.dart';

class PayslipPreviewDialog extends StatefulWidget {
  final Payslip payslip;

  const PayslipPreviewDialog({super.key, required this.payslip});

  @override
  State<PayslipPreviewDialog> createState() => _PayslipPreviewDialogState();
}

class _PayslipPreviewDialogState extends State<PayslipPreviewDialog> {
  bool _isGeneratingPdf = false;

  Future<void> _handleDownloadPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final path = await PayslipPdfService.generateAndSavePayslipPdf(widget.payslip);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF Payslip downloaded: ${path.split('/').last}"),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to generate PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payslip = widget.payslip;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 750),
        child: Column(
          children: [
            // Modal Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4338CA).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Color(0xFF4338CA), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Salary Slip - ${payslip.payPeriod}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            "${payslip.employeeName} (${payslip.employeeId})",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Info Header Card
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildMetaItem("Department", payslip.department, isDark),
                              _buildMetaItem("Designation", payslip.designation, isDark),
                              _buildMetaItem("PAN", payslip.panNumber, isDark),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMetaItem("Bank Account", payslip.bankAccount, isDark),
                              _buildMetaItem("Working Days", "${payslip.totalWorkingDays}", isDark),
                              _buildMetaItem("Present Days", "${payslip.presentDays}", isDark),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Salary Breakdown Card
                    SalaryBreakdownCard(
                      breakdown: payslip.breakdown,
                      isCompact: true,
                    ),
                  ],
                ),
              ),
            ),

            // Modal Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, size: 14),
                    label: Text(
                      "Close",
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isGeneratingPdf ? null : _handleDownloadPdf,
                    icon: _isGeneratingPdf
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download, size: 16),
                    label: Text(
                      _isGeneratingPdf ? "Generating PDF..." : "Download PDF Payslip",
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4338CA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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

  Widget _buildMetaItem(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 10,
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
}
