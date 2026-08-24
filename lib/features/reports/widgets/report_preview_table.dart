import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum PreviewCellType { normal, present, absent, late }

class _ProcessedPreviewCell {
  final String text;
  final PreviewCellType type;
  final bool isText;

  const _ProcessedPreviewCell({
    required this.text,
    required this.type,
    required this.isText,
  });
}

class ReportPreviewTable extends StatefulWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;
  final String searchQuery;

  const ReportPreviewTable({
    super.key,
    required this.columns,
    required this.rows,
    this.searchQuery = '',
  });

  @override
  State<ReportPreviewTable> createState() => _ReportPreviewTableState();
}

class _ReportPreviewTableState extends State<ReportPreviewTable> {
  final ScrollController _horizontalController = ScrollController();
  List<List<_ProcessedPreviewCell>> _processedRows = [];

  // Pagination State
  int _currentPage = 1;
  int _pageSize = 25;

  @override
  void initState() {
    super.initState();
    _precomputeRows();
  }

  @override
  void didUpdateWidget(covariant ReportPreviewTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.columns != oldWidget.columns ||
        widget.rows != oldWidget.rows ||
        widget.searchQuery != oldWidget.searchQuery) {
      _precomputeRows();
    }
  }

  void _precomputeRows() {
    final q = widget.searchQuery.toLowerCase().trim();

    final filtered = widget.rows.where((row) {
      if (q.isEmpty) return true;
      return row.any((cell) => cell?.toString().toLowerCase().contains(q) == true);
    }).toList();

    final List<List<_ProcessedPreviewCell>> list = [];
    for (final row in filtered) {
      final List<_ProcessedPreviewCell> cellList = [];
      for (int cIdx = 0; cIdx < row.length; cIdx++) {
        final cellVal = row[cIdx]?.toString() ?? '-';
        final colHeader = cIdx < widget.columns.length ? widget.columns[cIdx] : '';
        final isText = _isTextColumn(colHeader);

        PreviewCellType type = PreviewCellType.normal;
        final valLower = cellVal.toLowerCase();
        if (valLower == 'present' || valLower == '1.0' || valLower == 'p') {
          type = PreviewCellType.present;
        } else if (valLower == 'absent' || valLower == '0.0' || valLower == 'a') {
          type = PreviewCellType.absent;
        } else if (valLower.contains('late')) {
          type = PreviewCellType.late;
        }

        cellList.add(_ProcessedPreviewCell(
          text: cellVal,
          type: type,
          isText: isText,
        ));
      }
      list.add(cellList);
    }

    _processedRows = list;
    _currentPage = 1;
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  bool _isTextColumn(String header) {
    final h = header.toLowerCase();
    return h.contains('name') ||
        h.contains('department') ||
        h.contains('dept') ||
        h.contains('reason') ||
        h.contains('task') ||
        h.contains('remarks') ||
        h.contains('employee');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.columns.isEmpty || _processedRows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.table_chart_outlined, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Text(
                "No report table records to display",
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

    const double minColWidth = 125.0;
    final double tableWidth = widget.columns.length * minColWidth;
    final subtleBorder = isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0);

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
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3A6085),
                      ),
                      child: Row(
                        children: widget.columns.map((col) {
                          final isText = _isTextColumn(col);
                          return Container(
                            width: minColWidth,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Color(0xFF2C4A68)),
                              ),
                            ),
                            alignment: isText ? Alignment.centerLeft : Alignment.center,
                            child: Text(
                              col.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // ── Paginated High-Speed Rows ───────────────────────────
                  ...visibleRows.asMap().entries.map((entry) {
                    final rowIndex = entry.key;
                    final row = entry.value;
                    final isEven = (startIndex + rowIndex) % 2 == 0;

                    return RepaintBoundary(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: isEven
                              ? Colors.transparent
                              : (isDark ? const Color(0xFF161B22).withValues(alpha: 0.6) : const Color(0xFFF8FAFC)),
                          border: Border(
                            bottom: BorderSide(color: subtleBorder),
                          ),
                        ),
                        child: Row(
                          children: row.map((cell) {
                            Color cellColor;
                            FontWeight cellWeight;

                            switch (cell.type) {
                              case PreviewCellType.present:
                                cellColor = const Color(0xFF10B981);
                                cellWeight = FontWeight.bold;
                                break;
                              case PreviewCellType.absent:
                                cellColor = const Color(0xFFEF4444);
                                cellWeight = FontWeight.bold;
                                break;
                              case PreviewCellType.late:
                                cellColor = const Color(0xFFF59E0B);
                                cellWeight = FontWeight.w600;
                                break;
                              case PreviewCellType.normal:
                                cellColor = isDark ? Colors.white70 : const Color(0xFF1E293B);
                                cellWeight = FontWeight.normal;
                                break;
                            }

                            return Container(
                              width: minColWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: subtleBorder),
                                ),
                              ),
                              alignment: cell.isText ? Alignment.centerLeft : Alignment.center,
                              child: Text(
                                cell.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: cellWeight,
                                  color: cellColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
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
                  "Showing ${startIndex + 1}–$endIndex of $totalItems rows",
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
                            DropdownMenuItem(value: 15, child: Text("15 / page")),
                            DropdownMenuItem(value: 25, child: Text("25 / page")),
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
}

// [mod:2026-02-26T14:00:00+05:30]

// [upd:2026-05-04T09:00:00+05:30]

// [upd:2026-05-10T11:30:00+05:30]

// [rev:2026-08-24T11:00:00+05:30]
