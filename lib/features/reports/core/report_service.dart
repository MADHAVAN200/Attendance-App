import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/shared/constants/api_constants.dart';
import 'package:flutter_application/features/reports/core/report_history_model.dart';
import 'package:flutter_application/features/reports/core/report_models.dart';

class ReportService {
  final Dio _dio;
  static const String _historyKey = 'report_download_history';

  ReportService(this._dio);

  // 1. Fetch Real Employees from Database
  Future<List<Map<String, dynamic>>> fetchRealEmployees() async {
    try {
      final res = await _dio.get(ApiConstants.users);
      if (res.statusCode == 200 && res.data != null) {
        final raw = res.data is Map ? (res.data['data'] ?? res.data['users'] ?? []) : res.data;
        if (raw is List) {
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (e) {
      debugPrint("fetchRealEmployees notice: $e");
    }
    return [];
  }

  // 2. Fetch Real Departments from Database
  Future<List<Map<String, dynamic>>> fetchRealDepartments() async {
    try {
      final res = await _dio.get(ApiConstants.departments);
      if (res.statusCode == 200 && res.data != null) {
        final raw = res.data is Map ? (res.data['data'] ?? res.data['departments'] ?? []) : res.data;
        if (raw is List) {
          return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (e) {
      debugPrint("fetchRealDepartments notice: $e");
    }
    return [];
  }

  // 3. Fetch Real Report Preview from Backend Database
  Future<ReportPreviewResult> getPreview({
    required String type,
    String? month, // "YYYY-MM"
    String? date, // "YYYY-MM-DD"
    String? startDate, // "YYYY-MM-DD"
    String? endDate, // "YYYY-MM-DD"
    String? userId,
    String? deptId,
    String? desgId,
    String? shiftId,
  }) async {
    final query = {
      'type': type,
      if (month != null && month.isNotEmpty) 'month': month,
      if (date != null && date.isNotEmpty) 'date': date,
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
      if (userId != null && userId.isNotEmpty) 'user_id': userId,
      if (deptId != null && deptId.isNotEmpty) 'dept_id': deptId,
      if (desgId != null && desgId.isNotEmpty) 'desg_id': desgId,
      if (shiftId != null && shiftId.isNotEmpty) 'shift_id': shiftId,
      '_t': DateTime.now().millisecondsSinceEpoch,
    };

    // Attempt 1: Standard Backend Preview Endpoint
    try {
      final response = await _dio.get(ApiConstants.reportsPreview, queryParameters: query);

      if (response.statusCode == 200 && response.data != null) {
        final respMap = Map<String, dynamic>.from(response.data);
        if (respMap['ok'] == true && respMap['data'] != null) {
          final data = Map<String, dynamic>.from(respMap['data']);
          return await _buildResultFromBackendData(
            data,
            type: type,
            month: month,
            date: date,
            startDate: startDate,
            endDate: endDate,
            deptId: deptId,
            userId: userId,
          );
        }
      }
    } catch (e) {
      debugPrint("reportsPreview API returned error or fallback: $e. Fetching real DB attendance records.");
    }

    // Attempt 2: Fetch Live Database Attendance Records Directly
    return await _fetchLiveDatabaseMatrix(
      type: type,
      month: month,
      date: date,
      startDate: startDate,
      endDate: endDate,
      deptId: deptId,
      userId: userId,
    );
  }

  // Parse backend data into ReportPreviewResult and construct live matrix if needed
  Future<ReportPreviewResult> _buildResultFromBackendData(
    Map<String, dynamic> data, {
    required String type,
    String? month,
    String? date,
    String? startDate,
    String? endDate,
    String? deptId,
    String? userId,
  }) async {
    final List<String> columns = (data['columns'] as List? ?? []).map((e) => e.toString()).toList();
    final List<List<dynamic>> rows = (data['rows'] as List? ?? [])
        .map((r) => (r as List).map((cell) => cell).toList())
        .toList();

    // If backend preview already has full matrix
    if (data['matrix'] is List && (data['matrix'] as List).isNotEmpty) {
      final List<AttendanceMatrixEmployee> matrix = [];
      for (final item in data['matrix']) {
        matrix.add(AttendanceMatrixEmployee.fromJson(Map<String, dynamic>.from(item)));
      }
      final List<String> matrixDates = (data['matrixDates'] as List? ?? []).map((d) => d.toString()).toList();
      final summary = data['summary'] is Map
          ? ReportSummaryStats.fromJson(Map<String, dynamic>.from(data['summary']))
          : _calculateStatsFromMatrix(matrix);

      return ReportPreviewResult(
        columns: columns,
        rows: rows,
        summary: summary,
        matrix: matrix,
        matrixDates: matrixDates,
      );
    }

    // Build real matrix from live DB records
    final live = await _fetchLiveDatabaseMatrix(
      type: type,
      month: month,
      date: date,
      startDate: startDate,
      endDate: endDate,
      deptId: deptId,
      userId: userId,
    );

    return ReportPreviewResult(
      columns: columns.isNotEmpty ? columns : live.columns,
      rows: rows.isNotEmpty ? rows : live.rows,
      summary: live.summary,
      matrix: live.matrix,
      matrixDates: live.matrixDates,
    );
  }

  // Real Database Attendance Records Query & Aggregator
  Future<ReportPreviewResult> _fetchLiveDatabaseMatrix({
    required String type,
    String? month,
    String? date,
    String? startDate,
    String? endDate,
    String? deptId,
    String? userId,
  }) async {
    final targetMonth = month ?? DateFormat('yyyy-MM').format(DateTime.now());
    final parts = targetMonth.split('-');
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final mNum = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? DateTime.now().month;

    // Calculate dates in month
    final lastDay = DateTime(year, mNum + 1, 0).day;
    final List<String> matrixDates = [];
    for (int day = 1; day <= lastDay; day++) {
      matrixDates.add("$year-${mNum.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}");
    }

    // 1. Fetch Real Users from Database
    final usersList = await fetchRealEmployees();

    // 2. Fetch Real Raw Attendance Records from Database
    List<Map<String, dynamic>> rawRecords = [];
    try {
      final res = await _dio.get(
        ApiConstants.adminAttendanceRecords,
        queryParameters: {
          'month': targetMonth,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          if (deptId != null && deptId != 'All' && deptId.isNotEmpty) 'dept_id': deptId,
          if (userId != null && userId.isNotEmpty) 'user_id': userId,
        },
      );
      if (res.statusCode == 200 && res.data != null) {
        final d = res.data is Map ? (res.data['data'] ?? res.data['records'] ?? []) : res.data;
        if (d is List) {
          rawRecords = d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (e) {
      debugPrint("adminAttendanceRecords DB query notice: $e");
    }

    // Filter real users by department/user selection
    final filteredUsers = usersList.where((u) {
      final uId = u['user_id']?.toString() ?? u['id']?.toString() ?? '';
      final uDept = u['dept_name'] ?? u['department'] ?? '';
      final uDeptId = u['dept_id']?.toString() ?? '';

      if (userId != null && userId.isNotEmpty && uId != userId) return false;
      if (deptId != null && deptId.isNotEmpty && deptId != 'All' && deptId != 'All Departments') {
        if (uDept != deptId && uDeptId != deptId) return false;
      }
      return true;
    }).toList();

    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLeaves = 0;
    int totalHalfDay = 0;
    int totalLate = 0;
    double totalOvertime = 0.0;

    final List<AttendanceMatrixEmployee> matrix = [];

    for (final u in filteredUsers) {
      final uId = u['user_id']?.toString() ?? u['id']?.toString() ?? '';
      final uName = u['user_name'] ?? u['name'] ?? 'Staff Member';
      final uEmpId = u['employee_id'] ?? u['emp_id'] ?? uId;
      final uDept = u['dept_name'] ?? u['department'] ?? 'General';
      final uDesg = u['desg_name'] ?? u['designation'] ?? 'Employee';
      final uAvatar = u['avatar_url'] ?? u['avatarUrl'];

      final Map<String, AttendanceMatrixDayRecord> dayRecords = {};

      for (final dateStr in matrixDates) {
        // Find matching record from database
        final match = rawRecords.firstWhere(
          (r) =>
              (r['user_id']?.toString() == uId || r['employee_id']?.toString() == uEmpId) &&
              (r['date']?.toString() == dateStr || r['attendance_date']?.toString() == dateStr),
          orElse: () => <String, dynamic>{},
        );

        if (match.isNotEmpty) {
          final statusRaw = (match['status']?.toString() ?? 'P').toUpperCase();
          final clockIn = match['clock_in'] ?? match['clockIn'] ?? match['time_in'];
          final clockOut = match['clock_out'] ?? match['clockOut'] ?? match['time_out'];
          final duration = match['work_duration'] ?? match['worked_hours']?.toString();
          final ot = (match['overtime'] as num?)?.toDouble() ?? 0.0;
          final isLate = match['is_late'] == true || (match['late_minutes'] as num? ?? 0) > 0;
          final lateMin = (match['late_minutes'] as num?)?.toInt() ?? 0;
          final reason = match['reason'] ?? match['notes'];
          final inLoc = match['in_location'] ?? match['inLocation'];
          final outLoc = match['out_location'] ?? match['outLocation'];

          if (statusRaw == 'P' || statusRaw == 'PRESENT') totalPresent++;
          if (statusRaw == 'A' || statusRaw == 'ABSENT') totalAbsent++;
          if (statusRaw == 'L' || statusRaw == 'LEAVE') totalLeaves++;
          if (statusRaw == 'HD' || statusRaw == 'HALF_DAY') totalHalfDay++;
          if (isLate) totalLate++;
          totalOvertime += ot;

          dayRecords[dateStr] = AttendanceMatrixDayRecord(
            date: dateStr,
            status: statusRaw.startsWith('P') ? 'P' : statusRaw.startsWith('A') ? 'A' : statusRaw.startsWith('L') ? 'L' : statusRaw.startsWith('H') ? 'HD' : statusRaw,
            clockIn: clockIn?.toString(),
            clockOut: clockOut?.toString(),
            workDuration: duration?.toString(),
            overtimeHours: ot,
            inLocation: inLoc?.toString(),
            outLocation: outLoc?.toString(),
            isLate: isLate,
            lateMinutes: lateMin,
            reason: reason?.toString(),
          );
        } else {
          // Check if Sunday / Weekend
          final dt = DateTime.parse(dateStr);
          final isWeekend = dt.weekday == DateTime.sunday;

          dayRecords[dateStr] = AttendanceMatrixDayRecord(
            date: dateStr,
            status: isWeekend ? 'WO' : 'A',
          );
          if (!isWeekend && dt.isBefore(DateTime.now())) {
            totalAbsent++;
          }
        }
      }

      matrix.add(AttendanceMatrixEmployee(
        userId: uId,
        name: uName,
        employeeId: uEmpId,
        department: uDept,
        designation: uDesg,
        avatarUrl: uAvatar,
        dailyRecords: dayRecords,
      ));
    }

    final summary = ReportSummaryStats(
      present: totalPresent,
      absent: totalAbsent,
      leave: totalLeaves,
      halfDay: totalHalfDay,
      overtimeHours: totalOvertime,
      lateCount: totalLate,
    );

    // Build tabular spreadsheet columns & rows from live database
    final List<String> columns = ['EMP ID', 'EMPLOYEE NAME', 'DEPARTMENT', 'PRESENT', 'ABSENT', 'LEAVES', 'HALF DAY', 'LATE', 'TOTAL HOURS'];
    final List<List<dynamic>> rows = [];

    for (final emp in matrix) {
      int p = 0, a = 0, l = 0, hd = 0, lt = 0;
      emp.dailyRecords.forEach((_, r) {
        if (r.status == 'P') p++;
        if (r.status == 'A') a++;
        if (r.status == 'L') l++;
        if (r.status == 'HD') hd++;
        if (r.isLate) lt++;
      });
      final totalHrs = (p * 8.5) + (hd * 4.5);
      rows.add([emp.employeeId, emp.name, emp.department, '$p', '$a', '$l', '$hd', '$lt', '${totalHrs.toStringAsFixed(1)} hrs']);
    }

    return ReportPreviewResult(
      columns: columns,
      rows: rows,
      summary: summary,
      matrix: matrix,
      matrixDates: matrixDates,
    );
  }

  ReportSummaryStats _calculateStatsFromMatrix(List<AttendanceMatrixEmployee> matrix) {
    int p = 0, a = 0, l = 0, hd = 0, lt = 0;
    double ot = 0.0;

    for (final emp in matrix) {
      emp.dailyRecords.forEach((_, r) {
        if (r.status == 'P') p++;
        if (r.status == 'A') a++;
        if (r.status == 'L') l++;
        if (r.status == 'HD') hd++;
        if (r.isLate) lt++;
        ot += r.overtimeHours;
      });
    }

    return ReportSummaryStats(
      present: p,
      absent: a,
      leave: l,
      halfDay: hd,
      overtimeHours: ot,
      lateCount: lt,
    );
  }

  // 4. Export Report (Real File Generation)
  Future<String?> exportReport({
    required String type,
    required String format, // "xlsx", "csv", "pdf"
    String? month,
    String? date,
    String? startDate,
    String? endDate,
    String? userId,
    String? deptId,
  }) async {
    try {
      final result = await getPreview(
        type: type,
        month: month,
        date: date,
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        deptId: deptId,
      );

      if (result.columns.isEmpty) {
        throw Exception("No data available to export.");
      }

      final columns = result.columns;
      final rows = result.rows;

      String? savePath;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "Report_${type}_$timestamp.$format";

      if (format == 'xlsx') {
        savePath = await _generateExcel(fileName, columns, rows);
      } else if (format == 'pdf') {
        savePath = await _generatePdf(fileName, type, columns, rows);
      } else if (format == 'csv') {
        savePath = await _generateCsv(fileName, columns, rows);
      } else {
        throw Exception("Unsupported format: $format");
      }

      // Save History
      await _saveHistory(fileName, savePath, type);

      return savePath;
    } catch (e) {
      debugPrint("Export Failed: $e");
      rethrow;
    }
  }

  // --- File Generators ---

  Future<String> _generateExcel(String fileName, List<String> columns, List<List<dynamic>> rows) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Header
    sheet.appendRow(columns.map((c) => TextCellValue(c)).toList());

    // Rows
    for (var row in rows) {
      sheet.appendRow(row.map((cell) => TextCellValue(cell?.toString() ?? '-')).toList());
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception("Failed to encode Excel file");

    final path = await _getSavePath(fileName);
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  Future<String> _generateCsv(String fileName, List<String> columns, List<List<dynamic>> rows) async {
    List<List<dynamic>> csvData = [
      columns,
      ...rows,
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    final path = await _getSavePath(fileName);
    final file = File(path);
    await file.writeAsString(csv);
    return path;
  }

  Future<String> _generatePdf(String fileName, String title, List<String> columns, List<List<dynamic>> rows) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text("Attendance Report - ${title.toUpperCase()}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            ),
            pw.SizedBox(height: 14),
            pw.TableHelper.fromTextArray(
              headers: columns,
              data: rows.map((row) => row.map((e) => e?.toString() ?? '-').toList()).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    final path = await _getSavePath(fileName);
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }

  Future<String> _getSavePath(String fileName) async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    if (dir == null) throw Exception("Storage directory not found");
    return "${dir.path}/$fileName";
  }

  // --- History Management ---

  Future<void> _saveHistory(String fileName, String path, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    final newRecord = ReportHistory(
      fileName: fileName,
      path: path,
      timestamp: DateFormat('MMM dd, hh:mm a').format(DateTime.now()),
      type: type,
    );

    historyJson.insert(0, jsonEncode(newRecord.toJson()));
    if (historyJson.length > 50) historyJson.removeLast();

    await prefs.setStringList(_historyKey, historyJson);
  }

  Future<List<ReportHistory>> getDownloadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    return historyJson.map((e) {
      try {
        return ReportHistory.fromJson(jsonDecode(e));
      } catch (_) {
        return null;
      }
    }).whereType<ReportHistory>().toList();
  }
}

// commit-marker: 2026-02-25T16:45:00+05:30

// [mod:2026-02-26T09:00:00+05:30]

// [upd:2026-05-02T09:00:00+05:30]
