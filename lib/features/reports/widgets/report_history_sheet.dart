import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_application/features/reports/core/report_history_model.dart';
import 'package:flutter_application/shared/widgets/toast_helper.dart';

class ReportHistorySheet extends StatelessWidget {
  final List<ReportHistory> history;
  final bool isDrawer;
  final VoidCallback? onClose;

  const ReportHistorySheet({
    super.key,
    required this.history,
    this.isDrawer = false,
    this.onClose,
  });

  static void show(BuildContext context, List<ReportHistory> history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportHistorySheet(history: history),
    );
  }

  Future<void> _openFile(BuildContext context, String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done && context.mounted) {
        context.showToast("Could not open file: ${result.message}", isError: true);
      }
    } catch (e) {
      if (context.mounted) {
        context.showToast("Error opening file: $e", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDrawer)
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 18, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Text(
                  "DOWNLOAD HISTORY",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            if (isDrawer && onClose != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
              )
            else if (!isDrawer)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.folder_open_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    "No downloaded reports yet",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final item = history[idx];
                final isXlsx = item.fileName.endsWith('.xlsx');
                final isPdf = item.fileName.endsWith('.pdf');
                final isCsv = item.fileName.endsWith('.csv');

                final Color iconColor = isXlsx
                    ? const Color(0xFF10B981)
                    : isPdf
                        ? const Color(0xFFEF4444)
                        : isCsv
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF6366F1);

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isPdf
                              ? Icons.picture_as_pdf_outlined
                              : isXlsx
                                  ? Icons.table_view_outlined
                                  : Icons.insert_drive_file_outlined,
                          size: 16,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.fileName,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${item.type.toUpperCase()} • ${item.timestamp}",
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.file_open_outlined, size: 18, color: Color(0xFF6366F1)),
                        onPressed: () => _openFile(context, item.path),
                        tooltip: "Open File",
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );

    if (isDrawer) {
      return Container(
        width: 320,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          border: Border(
            left: BorderSide(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: SingleChildScrollView(child: content),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: content,
    );
  }
}

// [mod:2026-02-26T17:00:00+05:30]
