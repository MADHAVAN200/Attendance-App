import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application/features/labour/core/labour_models.dart';

class LabourExcelExportHelper {
  /// Exports the monthly attendance grid matrix for a site to an Excel (.xlsx) file.
  static Future<String> exportMonthlyGridToExcel({
    required List<LabourMonthlyRow> grid,
    required String siteName,
    required DateTime month,
  }) async {
    final excel = Excel.createExcel();
    final String sheetName = DateFormat('MMM_yyyy').format(month);
    final Sheet sheet = excel[sheetName];

    // Remove default sheet if present
    if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    final year = month.year;
    final monthNum = month.month;
    final daysInMonth = DateTime(year, monthNum + 1, 0).day;

    // Header Row
    final List<String> headers = [
      'Worker Name',
      'Role',
      ...List.generate(daysInMonth, (i) => 'Day ${i + 1}'),
      'Present (P)',
      'Half Day (H)',
      'Absent (A)',
      'Total Days',
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Data Rows
    for (final row in grid) {
      final List<CellValue> rowCells = [
        TextCellValue(row.name),
        TextCellValue(row.role),
      ];

      for (int i = 1; i <= daysInMonth; i++) {
        final status = row.days['$i'] ?? '-';
        rowCells.add(TextCellValue(status));
      }

      final totalTracked = row.presentCount + row.halfDayCount + row.absentCount;

      rowCells.addAll([
        IntCellValue(row.presentCount),
        IntCellValue(row.halfDayCount),
        IntCellValue(row.absentCount),
        IntCellValue(totalTracked),
      ]);

      sheet.appendRow(rowCells);
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('Failed to generate Excel file');
    }

    final directory = await getApplicationDocumentsDirectory();
    final sanitizedSite = siteName.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    final fileName = 'Labour_Attendance_${sanitizedSite}_${DateFormat('yyyy_MM').format(month)}.xlsx';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // Open file using open_filex
    await OpenFilex.open(filePath);

    return filePath;
  }

  /// Exports the labour salary payouts and advances summary to an Excel (.xlsx) file.
  static Future<String> exportPayoutsToExcel({
    required List<LabourPayoutSummary> payouts,
    required String siteName,
    required String monthStr,
  }) async {
    final excel = Excel.createExcel();
    const String sheetName = 'Payouts_Summary';
    final Sheet sheet = excel[sheetName];

    if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    // Headers
    final List<String> headers = [
      'Worker Name',
      'Role',
      'Site Name',
      'Days Present',
      'Daily Rate (Rs.)',
      'Overtime (Hrs)',
      'Overtime Rate (Rs.)',
      'Total Earned (Rs.)',
      'Total Advance (Rs.)',
      'Net Payout (Rs.)',
      'Status',
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Data Rows
    for (final p in payouts) {
      sheet.appendRow([
        TextCellValue(p.name),
        TextCellValue(p.role),
        TextCellValue(p.siteName),
        IntCellValue(p.daysPresent),
        DoubleCellValue(p.dailyRate),
        DoubleCellValue(p.overtimeHours),
        DoubleCellValue(p.overtimeRate),
        DoubleCellValue(p.accruedCredit),
        DoubleCellValue(p.totalAdvance),
        DoubleCellValue(p.netPayable),
        TextCellValue(p.status.toUpperCase()),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('Failed to generate Excel file');
    }

    final directory = await getApplicationDocumentsDirectory();
    final sanitizedSite = siteName.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    final fileName = 'Labour_Payouts_${sanitizedSite}_$monthStr.xlsx';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(bytes);

    await OpenFilex.open(filePath);

    return filePath;
  }
}

// [upd:2026-04-09T17:00:00+05:30]
