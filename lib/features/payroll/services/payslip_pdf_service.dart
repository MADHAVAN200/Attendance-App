import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/payroll_model.dart';

class PayslipPdfService {
  /// Generates a PDF Payslip document and saves it locally.
  /// Returns the absolute filepath of the generated PDF file.
  static Future<String> generateAndSavePayslipPdf(Payslip payslip) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#4338CA'); // Indigo brand color
    final headerBg = PdfColor.fromHex('#F8FAFC');
    final borderColor = PdfColor.fromHex('#E2E8F0');
    final textColor = PdfColor.fromHex('#1E293B');
    final lightTextColor = PdfColor.fromHex('#64748B');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Corporate Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: headerBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "MANO ATTENDANCE & ERP",
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Enterprise Workforce & Payroll Management System",
                          style: pw.TextStyle(fontSize: 10, color: lightTextColor),
                        ),
                        pw.Text(
                          "GSTIN: 33AAAAA0000A1Z5 | Reg: DL-889102-IN",
                          style: pw.TextStyle(fontSize: 8, color: lightTextColor),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            "PAYSLIP",
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          "Pay Period: ${payslip.payPeriod}",
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textColor),
                        ),
                        pw.Text(
                          "Slip Ref: ${payslip.id}",
                          style: pw.TextStyle(fontSize: 8, color: lightTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // 2. Employee Metadata Grid
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        _buildMetaCell("Employee Name", payslip.employeeName, textColor, lightTextColor),
                        _buildMetaCell("Employee Code", payslip.employeeId, textColor, lightTextColor),
                        _buildMetaCell("Department", payslip.department, textColor, lightTextColor),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      children: [
                        _buildMetaCell("Designation", payslip.designation, textColor, lightTextColor),
                        _buildMetaCell("PAN Number", payslip.panNumber, textColor, lightTextColor),
                        _buildMetaCell("Bank Account", payslip.bankAccount, textColor, lightTextColor),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      children: [
                        _buildMetaCell("Total Days", "${payslip.totalWorkingDays}", textColor, lightTextColor),
                        _buildMetaCell("Days Present", "${payslip.presentDays}", textColor, lightTextColor),
                        _buildMetaCell("Unpaid Leaves", "${payslip.unpaidLeaves} days", textColor, lightTextColor),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // 3. Earnings & Deductions Breakdown Table
              pw.Text(
                "SALARY BREAKDOWN",
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(1),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: headerBg),
                    children: [
                      _buildTableHeader("EARNINGS"),
                      _buildTableHeader("AMOUNT (₹)", alignRight: true),
                      _buildTableHeader("DEDUCTIONS"),
                      _buildTableHeader("AMOUNT (₹)", alignRight: true),
                    ],
                  ),

                  // Basic vs PF
                  pw.TableRow(children: [
                    _buildTableCell("Basic Salary"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.basic), alignRight: true),
                    _buildTableCell("Provident Fund (PF - 12%)"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.pf), alignRight: true),
                  ]),

                  // HRA vs ESI
                  pw.TableRow(children: [
                    _buildTableCell("House Rent Allowance (HRA)"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.hra), alignRight: true),
                    _buildTableCell("ESI Deduction (0.75%)"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.esi), alignRight: true),
                  ]),

                  // Special Allowance vs TDS
                  pw.TableRow(children: [
                    _buildTableCell("Special Allowance"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.specialAllowance), alignRight: true),
                    _buildTableCell("Tax Deducted at Source (TDS)"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.tds), alignRight: true),
                  ]),

                  // Overtime vs Leave Deduction
                  pw.TableRow(children: [
                    _buildTableCell("Overtime Pay (${payslip.overtimeHours} hrs)"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.overtimePay), alignRight: true),
                    _buildTableCell("Unpaid Leave Deduction"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.leaveDeductions), alignRight: true),
                  ]),

                  // Empty / Advance
                  pw.TableRow(children: [
                    _buildTableCell("-"),
                    _buildTableCell("-", alignRight: true),
                    _buildTableCell("Salary Advance / Loan"),
                    _buildTableCell(NumberFormat('#,##,##0').format(payslip.breakdown.salaryAdvance), alignRight: true),
                  ]),

                  // Subtotals Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: headerBg),
                    children: [
                      _buildTableCell("GROSS EARNINGS", isBold: true),
                      _buildTableCell("₹ ${NumberFormat('#,##,##0').format(payslip.breakdown.totalEarnings)}", isBold: true, alignRight: true),
                      _buildTableCell("TOTAL DEDUCTIONS", isBold: true),
                      _buildTableCell("₹ ${NumberFormat('#,##,##0').format(payslip.breakdown.totalDeductions)}", isBold: true, alignRight: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // 4. Net Salary Highlight Card & Amount in Words
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(8),
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
                        pw.SizedBox(height: 4),
                        pw.Text(
                          numberToWords(payslip.netPay),
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      payslip.formattedNetPay,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // 5. Signatures and Disclaimers
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.green800, width: 1.5),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          "STATUS: PAID / DISBURSED",
                          style: pw.TextStyle(
                            color: PdfColors.green800,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        "This is a system-generated payslip and does not require a physical signature.",
                        style: pw.TextStyle(fontSize: 8, color: lightTextColor),
                      ),
                      pw.Text(
                        "Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(payslip.generatedDate)}",
                        style: pw.TextStyle(fontSize: 8, color: lightTextColor),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 140,
                        height: 1,
                        color: borderColor,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Authorized Signatory",
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textColor),
                      ),
                      pw.Text(
                        "MANO Payroll Dept",
                        style: pw.TextStyle(fontSize: 8, color: lightTextColor),
                      ),
                    ],
                  ),
                ],
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

  static pw.Widget _buildMetaCell(String label, String value, PdfColor textColor, PdfColor labelColor) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label.toUpperCase(), style: pw.TextStyle(fontSize: 7, color: labelColor, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, color: textColor, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _buildTableHeader(String title, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        title,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
      ),
    );
  }

  static pw.Widget _buildTableCell(String content, {bool isBold = false, bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        content,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isBold ? PdfColors.black : PdfColors.grey900,
        ),
      ),
    );
  }
}
