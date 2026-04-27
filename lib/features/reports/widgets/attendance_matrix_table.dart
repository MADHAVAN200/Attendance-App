import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/features/reports/core/report_models.dart';
import 'package:flutter_application/features/reports/widgets/attendance_detail_sheet.dart';

class _DateHeaderInfo {
  final String dateStr;
  final String monthShort;
  final String dayNum;
  final String weekdayShort;
  final bool isSunday;

  const _DateHeaderInfo({
    required this.dateStr,
    required this.monthShort,
    required this.dayNum,
    required this.weekdayShort,
    required this.isSunday,
  });
}

class _ProcessedEmployeeRow {
  final AttendanceMatrixEmployee employee;
  final String initials;
  final int pCount;
  final int aCount;
  final int lCount;
  final List<AttendanceMatrixDayRecord> dayRecords;

  const _ProcessedEmployeeRow({
    required this.employee,
    required this.initials,
    required this.pCount,
    required this.aCount,
    required this.lCount,
    required this.dayRecords,
  });
}

class AttendanceMatrixTable extends StatefulWidget {
  final List<AttendanceMatrixEmployee> matrix;
  final List<String> dates;
  final String searchQuery;

  const AttendanceMatrixTable({
    super.key,
    required this.matrix,
    required this.dates,
    this.searchQuery = '',
  });

  @override
  State<AttendanceMatrixTable> createState() => _AttendanceMatrixTableState();
}

class _AttendanceMatrixTableState extends State<AttendanceMatrixTable> {
  final ScrollController _horizontalScroll = ScrollController();
  List<_DateHeaderInfo> _cachedHeaders = [];
  List<_ProcessedEmployeeRow> _processedRows = [];

  // Pagination State
  int _currentPage = 1;
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _recomputeAll();
  }

  @override
  void didUpdateWidget(covariant AttendanceMatrixTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dates != oldWidget.dates ||
        widget.matrix != oldWidget.matrix ||
        widget.searchQuery != oldWidget.searchQuery) {
      _recomputeAll();
    }
  }

  void _recomputeAll() {
    // 1. Precompute Headers
    final List<_DateHeaderInfo> headers = [];
    for (final dStr in widget.dates) {
      DateTime? dt;
      try {
        dt = DateTime.parse(dStr);
      } catch (_) {}

      final isSun = dt?.weekday == DateTime.sunday;
      headers.add(_DateHeaderInfo(
        dateStr: dStr,
        monthShort: dt != null ? DateFormat('MMM').format(dt).toUpperCase() : 'DAY',
        dayNum: dt != null ? '${dt.day}' : '0',
        weekdayShort: dt != null ? DateFormat('E').format(dt).toUpperCase() : '',
        isSunday: isSun,
      ));
    }
    _cachedHeaders = headers;

    // 2. Filter Matrix by Search
    final q = widget.searchQuery.toLowerCase().trim();
    final filtered = widget.matrix.where((emp) {
      if (q.isEmpty) return true;
      return emp.name.toLowerCase().contains(q) ||
          emp.employeeId.toLowerCase().contains(q) ||
          emp.department.toLowerCase().contains(q);
    }).toList();

    // 3. Pre-process and Cache Rows
    final List<_ProcessedEmployeeRow> rows = [];
    for (final emp in filtered) {
      int p = 0, a = 0, l = 0;
      final List<AttendanceMatrixDayRecord> dayRecs = [];

      for (final hdr in headers) {
        final rec = emp.dailyRecords[hdr.dateStr] ??
            AttendanceMatrixDayRecord(date: hdr.dateStr, status: hdr.isSunday ? 'WO' : 'A');
        if (rec.status == 'P') p++;
        if (rec.status == 'A') a++;
        if (rec.status == 'L') l++;
        dayRecs.add(rec);
      }

      final initials = emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E';
      rows.add(_ProcessedEmployeeRow(
        employee: emp,
        initials: initials,
        pCount: p,
        aCount: a,
        lCount: l,
        dayRecords: dayRecs,
      ));
    }

    _processedRows = rows;
    _currentPage = 1;
  }

  @override
  void dispose() {
    _horizontalScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_processedRows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_search_outlined, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Text(
                "No employee attendance records found",
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Pagination Slicing
    final totalItems = _processedRows.length;
    final totalPages = (_pageSize == -1) ? 1 : ((totalItems / _pageSize).ceil());
    final startIndex = (_pageSize == -1) ? 0 : (_currentPage - 1) * _pageSize;
    final endIndex = (_pageSize == -1) ? totalItems : (startIndex + _pageSize).clamp(0, totalItems);
    final visibleRows = _processedRows.sublist(startIndex, endIndex);

    const double employeeColWidth = 170.0;
    const double dayColWidth = 42.0;
    const double totalsColWidth = 100.0;
    final double tableWidth = employeeColWidth + (_cachedHeaders.length * dayColWidth) + totalsColWidth;

    final headerBg = isDark ? const Color(0xFF1E242C) : const Color(0xFFEEF2F6);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);
    final subtleBorder = isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fast Horizontal Scroll Table ─────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                  // ── Header Row ──────────────────────────────────────────
                  RepaintBoundary(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: headerBg,
                        border: Border(
                          top: BorderSide(color: borderColor),
                          bottom: BorderSide(color: borderColor, width: 1.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Employee Column Header
                          SizedBox(
                            width: employeeColWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "EMPLOYEE",
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),

                          // Day Columns Headers
                          ..._cachedHeaders.map((hdr) {
                            return Container(
                              width: dayColWidth,
                              decoration: BoxDecoration(
                                color: hdr.isSunday
                                    ? (isDark ? const Color(0xFF262C36) : const Color(0xFFE2E8F0).withValues(alpha: 0.6))
                                    : Colors.transparent,
                                border: Border(
                                  left: BorderSide(color: subtleBorder),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    hdr.monthShort,
                                    style: GoogleFonts.poppins(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                      color: isDark ? const Color(0xFF8B949E) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    hdr.dayNum,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                      color: hdr.isSunday
                                          ? const Color(0xFFEF4444)
                                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    hdr.weekdayShort,
                                    style: GoogleFonts.poppins(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                      color: isDark ? const Color(0xFF8B949E) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // Totals Summary Header
                          Container(
                            width: totalsColWidth,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              border: Border(left: BorderSide(color: borderColor)),
                            ),
                            child: Center(
                              child: Text(
                                "TOTALS (P/A/L)",
                                style: GoogleFonts.poppins(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Paginated High-Speed Rows ───────────────────────────
                  ...visibleRows.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final rowData = entry.value;
                    final isEven = (startIndex + idx) % 2 == 0;

                    return RepaintBoundary(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isEven
                              ? Colors.transparent
                              : (isDark ? const Color(0xFF161B22).withValues(alpha: 0.6) : const Color(0xFFF8FAFC)),
                          border: Border(
                            bottom: BorderSide(color: subtleBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Employee Identity Cell
                            Container(
                              width: employeeColWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 13,
                                    backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                    child: Text(
                                      rowData.initials,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rowData.employee.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${rowData.employee.employeeId} • ${rowData.employee.department}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 8.5,
                                            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Day Status Cells (Pre-indexed lookup)
                            ...rowData.dayRecords.map((rec) {
                              return Container(
                                width: dayColWidth,
                                decoration: BoxDecoration(
                                  border: Border(left: BorderSide(color: subtleBorder)),
                                ),
                                child: Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => AttendanceDetailSheet.show(
                                        context,
                                        employee: rowData.employee,
                                        record: rec,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: rec.statusColor.withValues(alpha: isDark ? 0.22 : 0.12),
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: rec.statusColor.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            rec.shortStatus,
                                            style: GoogleFonts.poppins(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: rec.statusColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),

                            // Totals Cell
                            Container(
                              width: totalsColWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border(left: BorderSide(color: borderColor)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildMiniCount('${rowData.pCount}', const Color(0xFF10B981), isDark),
                                  const SizedBox(width: 3),
                                  _buildMiniCount('${rowData.aCount}', const Color(0xFFEF4444), isDark),
                                  const SizedBox(width: 3),
                                  _buildMiniCount('${rowData.lCount}', const Color(0xFF0284C7), isDark),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

        // ── Smooth Pagination Bar ────────────────────────────────────────
        if (totalItems > 15) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Showing ${startIndex + 1}–$endIndex of $totalItems employees",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                  ),
                ),
                Row(
                  children: [
                    // Rows Per Page Selector
                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF21262D) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _pageSize,
                          isDense: true,
                          dropdownColor: isDark ? const Color(0xFF1E242C) : Colors.white,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          icon: const Icon(Icons.arrow_drop_down, size: 16),
                          items: const [
                            DropdownMenuItem(value: 10, child: Text("10 / page")),
                            DropdownMenuItem(value: 20, child: Text("20 / page")),
                            DropdownMenuItem(value: 50, child: Text("50 / page")),
                            DropdownMenuItem(value: -1, child: Text("All")),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _pageSize = val;
                                _currentPage = 1;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Previous Page
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(28, 28),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$_currentPage / $totalPages",
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),

                    // Next Page
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(28, 28),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMiniCount(String count, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        count,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// [mod:2026-02-26T17:00:00+05:30]

// [upd:2026-04-27T11:30:00+05:30]
