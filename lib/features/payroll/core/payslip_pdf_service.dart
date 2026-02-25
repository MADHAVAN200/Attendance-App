import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_application/features/payroll/core/payroll_model.dart';

// Currency formatter using "Rs." prefix (avoids ₹ glyph missing in embedded fonts)
String _fmtCurrency(double amount) {
  final formatted = NumberFormat('#,##,##0.00', 'en_IN').format(amount);
  return 'Rs. $formatted';
}

class PayslipPdfService {
  /// Generates a single-page PDF Payslip document matching Attendance-Web (PayslipService.js).
  /// Returns the absolute filepath of the generated PDF file.
  static Future<String> generateAndSavePayslipPdf(Payslip payslip) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#0969DA'); // Web Accent Blue
    final textColor = PdfColor.fromHex('#24292F');
    final secondaryTextColor = PdfColor.fromHex('#57606A');
    final lightBgColor = PdfColor.fromHex('#F6F8FA');
    final tableHeaderBg = PdfColor.fromHex('#EAEEF2');
    final borderColor = PdfColor.fromHex('#D0D7DE');
    final greenStatusColor = PdfColor.fromHex('#2DA44E');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "MANO TECHNOLOGIES",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "Monthly Payroll Statement",
                        style: pw.TextStyle(fontSize: 9, color: secondaryTextColor),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Payslip for ${payslip.payPeriod}",
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "Status: ${payslip.status.label.toUpperCase()}",
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: greenStatusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(color: borderColor, thickness: 1),
              pw.SizedBox(height: 10),

              // 2. Employee Information Section
              pw.Text(
                "Employee Information",
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: lightBgColor,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("Employee Code:", payslip.employeeId, textColor, secondaryTextColor),
                          pw.SizedBox(height: 5),
                          _buildInfoRow("Employee Name:", payslip.employeeName, textColor, secondaryTextColor),
                          pw.SizedBox(height: 5),
                          _buildInfoRow("Email Address:", "${payslip.employeeId.toLowerCase()}@mano.co.in", textColor, secondaryTextColor),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("Department:", payslip.department, textColor, secondaryTextColor),
                          pw.SizedBox(height: 5),
                          _buildInfoRow("Designation:", payslip.designation, textColor, secondaryTextColor),
                          pw.SizedBox(height: 5),
                          _buildInfoRow("Payroll ID:", payslip.id, textColor, secondaryTextColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // 3. Attendance & Leave Summary Section
              pw.Text(
                "Attendance & Leave Summary",
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 1),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: tableHeaderBg),
                    children: [
                      _buildHeaderCell("Present"),
                      _buildHeaderCell("Half Days"),
                      _buildHeaderCell("Absent"),
                      _buildHeaderCell("On Leave"),
                      _buildHeaderCell("Holidays"),
                      _buildHeaderCell("Week Offs"),
                      _buildHeaderCell("Overtime"),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildValueCell(payslip.presentDays.toStringAsFixed(2)),
                      _buildValueCell(payslip.halfDays.toStringAsFixed(2)),
                      _buildValueCell(payslip.absentDays.toStringAsFixed(2)),
                      _buildValueCell(payslip.paidLeaveDays.toStringAsFixed(2)),
                      _buildValueCell(payslip.holidayDays.toStringAsFixed(2)),
                      _buildValueCell(payslip.weeklyOffDays.toStringAsFixed(2)),
                      _buildValueCell("${payslip.overtimeHours.toStringAsFixed(1)} hrs"),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              // 4. Salary & Deductions Details Breakdown Table
              pw.Text(
                "Salary & Deductions Details",
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // EARNINGS TABLE (Left side)
                  pw.Expanded(
                    child: pw.Table(
                      border: pw.TableBorder.all(color: borderColor, width: 1),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: tableHeaderBg),
                          children: [
                            _buildHeaderCell("EARNINGS"),
                            _buildHeaderCell("AMOUNT", alignRight: true),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            _buildValueCell("Gross Monthly Salary"),
                            _buildValueCell(_fmtCurrency(payslip.grossSalary), alignRight: true),
                          ],
                        ),
                        if (payslip.overtimeAmount > 0)
                          pw.TableRow(
                            children: [
                              _buildValueCell("Overtime Allowance (${payslip.overtimeHours} hrs)"),
                              _buildValueCell(_fmtCurrency(payslip.overtimeAmount), alignRight: true),
                            ],
                          ),
                        ...payslip.adjustments
                            .where((a) => a.type == 'addition')
                            .map((a) => pw.TableRow(
                                  children: [
                                    _buildValueCell(a.label),
                                    _buildValueCell(_fmtCurrency(a.amount), alignRight: true),
                                  ],
                                )),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 10),

                  // DEDUCTIONS TABLE (Right side)
                  pw.Expanded(
                    child: pw.Table(
                      border: pw.TableBorder.all(color: borderColor, width: 1),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: tableHeaderBg),
                          children: [
                            _buildHeaderCell("DEDUCTIONS"),
                            _buildHeaderCell("AMOUNT", alignRight: true),
                          ],
                        ),
                        pw.TableRow(
                          children: [
                            _buildValueCell("Loss of Pay (LOP) Deduction"),
                            _buildValueCell(_fmtCurrency(payslip.lopDeduction), alignRight: true),
                          ],
                        ),
                        ...payslip.adjustments
                            .where((a) => a.type == 'deduction')
                            .map((a) => pw.TableRow(
                                  children: [
                                    _buildValueCell(a.label),
                                    _buildValueCell(_fmtCurrency(a.amount), alignRight: true),
                                  ],
                                )),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // 5. Net Salary Highlight Block
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "NET PAYABLE SALARY",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          numberToWords(payslip.netPay),
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 8,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      _fmtCurrency(payslip.netPay),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),
              pw.Text(
                "* Deductions calculated based on ${payslip.lopDays.toStringAsFixed(1)} LOP (Loss of Pay) days in ${payslip.payPeriod}.",
                style: pw.TextStyle(fontSize: 8, color: secondaryTextColor, fontStyle: pw.FontStyle.italic),
              ),

              pw.Spacer(),

              // 6. Footer Section
              pw.Divider(color: borderColor, thickness: 1),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  "This is a computer-generated payslip and does not require a physical signature.",
                  style: pw.TextStyle(fontSize: 8, color: secondaryTextColor),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  "Powered by MANO Attendance HRMS Platform v1.0",
                  style: pw.TextStyle(fontSize: 8, color: secondaryTextColor),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save File
    final dir = await getApplicationDocumentsDirectory();
    final fileName = "Payslip_${payslip.employeeId}_${payslip.payPeriod.replaceAll(' ', '_')}.pdf";
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    debugPrint("Payslip PDF saved to: ${file.path}");
    return file.path;
  }

  /// Opens the generated PDF using open_filex
  static Future<void> openPayslipPdf(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint("Could not open PDF file: ${result.message}");
      }
    } catch (e) {
      debugPrint("Error opening PDF file: $e");
    }
  }

  static pw.Widget _buildInfoRow(String label, String value, PdfColor textColor, PdfColor labelColor) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 95,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 8, color: labelColor, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, color: textColor, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String title, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        title,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget _buildValueCell(String content, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        content,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: 8, color: PdfColors.black),
      ),
    );
  }
}

// [mod:2026-02-25T11:30:00+05:30]
