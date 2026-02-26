import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/features/reports/widgets/custom_month_picker_dialog.dart';
import 'package:flutter_application/features/reports/widgets/custom_dropdown_selector.dart';
import 'package:flutter_application/features/leave/widgets/custom_date_picker_dialog.dart';

class ReportFilterCard extends StatelessWidget {
  final String selectedReportType;
  final ValueChanged<String> onReportTypeChanged;

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime start, DateTime end) onDateRangeChanged;
  final bool useDateRange;
  final ValueChanged<bool> onToggleDateRange;

  final String selectedDept;
  final ValueChanged<String> onDeptChanged;
  final List<String> departments;

  final String selectedFormat;
  final ValueChanged<String> onFormatChanged;

  final VoidCallback onGenerate;
  final VoidCallback onExport;
  final VoidCallback onToggleHistory;

  final bool isGenerating;
  final bool isExporting;
  final bool isCompact;

  const ReportFilterCard({
    super.key,
    required this.selectedReportType,
    required this.onReportTypeChanged,
    required this.selectedDate,
    required this.onDateChanged,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
    required this.useDateRange,
    required this.onToggleDateRange,
    required this.selectedDept,
    required this.onDeptChanged,
    this.departments = const ['All Departments'],
    required this.selectedFormat,
    required this.onFormatChanged,
    required this.onGenerate,
    required this.onExport,
    required this.onToggleHistory,
    this.isGenerating = false,
    this.isExporting = false,
    this.isCompact = false,
  });

  static const List<DropdownOption<String>> reportTypeOptions = [
    DropdownOption(value: 'matrix_monthly', label: 'Monthly Matrix', subtitle: 'Day-by-day attendance grid', icon: Icons.calendar_view_month_rounded),
    DropdownOption(value: 'detailed', label: 'Detailed Attendance', subtitle: 'Punch times, durations & locations', icon: Icons.table_chart_outlined),
    DropdownOption(value: 'daily', label: 'Daily Attendance', subtitle: 'Single-day status report', icon: Icons.today_rounded),
    DropdownOption(value: 'weekly', label: 'Weekly Summary', subtitle: '7-day work hours & attendance', icon: Icons.view_week_rounded),
    DropdownOption(value: 'monthly', label: 'Monthly Summary', subtitle: 'Total present, absent & leaves', icon: Icons.summarize_outlined),
    DropdownOption(value: 'lateness_report', label: 'Late / Early Departure', subtitle: 'Late minutes and reasons', icon: Icons.warning_amber_rounded),
    DropdownOption(value: 'overtime_report', label: 'Overtime Summary', subtitle: 'Extra hours worked and approvals', icon: Icons.more_time_rounded),
    DropdownOption(value: 'leave', label: 'Leave Summary', subtitle: 'Approved leaves and categories', icon: Icons.beach_access_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deptOptions = departments.map((d) {
      return DropdownOption<String>(
        value: d,
        label: d,
        icon: d == 'All Departments' ? Icons.domain_rounded : Icons.business_outlined,
      );
    }).toList();

    if (isCompact) {
      return _buildMobileCard(context, isDark, deptOptions);
    }

    return _buildDesktopTabletCard(context, isDark, deptOptions);
  }

  // ── Desktop / Tablet Landscape Filter Card ──────────────────────────────
  Widget _buildDesktopTabletCard(
    BuildContext context,
    bool isDark,
    List<DropdownOption<String>> deptOptions,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Custom Report Type Selector
              Expanded(
                flex: 3,
                child: CustomDropdownSelector<String>(
                  label: "Report Type",
                  placeholder: "Select Report Type",
                  icon: Icons.description_outlined,
                  selectedValue: selectedReportType,
                  options: reportTypeOptions,
                  onSelected: onReportTypeChanged,
                ),
              ),
              const SizedBox(width: 10),

              // Custom Date / Month Selector
              Expanded(
                flex: 3,
                child: _buildCustomDateTrigger(context, isDark),
              ),
              const SizedBox(width: 10),

              // Custom Department Selector
              Expanded(
                flex: 2,
                child: CustomDropdownSelector<String>(
                  label: "Department",
                  placeholder: "All Departments",
                  icon: Icons.business_outlined,
                  selectedValue: selectedDept,
                  options: deptOptions,
                  onSelected: onDeptChanged,
                  isSearchable: true,
                ),
              ),
              const SizedBox(width: 10),

              // Format Selector
              Expanded(
                flex: 2,
                child: _buildFormatSelector(isDark),
              ),
              const SizedBox(width: 10),

              // Actions: Generate Preview, Export, History
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Generate Button
                  ElevatedButton.icon(
                    onPressed: isGenerating ? null : onGenerate,
                    icon: isGenerating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(
                      "Generate",
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Export Button
                  ElevatedButton.icon(
                    onPressed: isExporting ? null : onExport,
                    icon: isExporting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded, size: 16),
                    label: Text(
                      "Export",
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // History Toggle
                  IconButton(
                    onPressed: onToggleHistory,
                    icon: const Icon(Icons.history_rounded, size: 20),
                    tooltip: "Recent History",
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mobile Compact Filter Card ──────────────────────────────────────────
  Widget _buildMobileCard(
    BuildContext context,
    bool isDark,
    List<DropdownOption<String>> deptOptions,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Report Type
          CustomDropdownSelector<String>(
            label: "Report Type",
            placeholder: "Select Report Type",
            icon: Icons.description_outlined,
            selectedValue: selectedReportType,
            options: reportTypeOptions,
            onSelected: onReportTypeChanged,
          ),
          const SizedBox(height: 8),

          // Row 2: Date + Department
          Row(
            children: [
              Expanded(child: _buildCustomDateTrigger(context, isDark)),
              const SizedBox(width: 8),
              Expanded(
                child: CustomDropdownSelector<String>(
                  label: "Department",
                  placeholder: "All Departments",
                  icon: Icons.business_outlined,
                  selectedValue: selectedDept,
                  options: deptOptions,
                  onSelected: onDeptChanged,
                  isSearchable: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Format Selector + Action Buttons
          Row(
            children: [
              // Format
              Expanded(
                flex: 3,
                child: _buildFormatSelector(isDark),
              ),
              const SizedBox(width: 8),

              // Generate
              ElevatedButton(
                onPressed: isGenerating ? null : onGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isGenerating
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh_rounded, size: 16),
              ),
              const SizedBox(width: 6),

              // Export
              ElevatedButton(
                onPressed: isExporting ? null : onExport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isExporting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        children: [
                          const Icon(Icons.download_rounded, size: 15),
                          const SizedBox(width: 4),
                          Text("Export", style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
              const SizedBox(width: 6),

              // History
              IconButton(
                onPressed: onToggleHistory,
                icon: const Icon(Icons.history_rounded, size: 18),
                tooltip: "History",
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Custom Date & Month Picker Trigger ───────────────────────────────────
  Widget _buildCustomDateTrigger(BuildContext context, bool isDark) {
    final bool isMonthly = selectedReportType == 'matrix_monthly' || selectedReportType == 'monthly';
    final fmt = isMonthly ? DateFormat('MMMM yyyy') : DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMonthly ? "SELECT MONTH" : "SELECT DATE",
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            if (isMonthly) {
              final picked = await CustomMonthPickerDialog.show(
                context,
                initialDate: selectedDate,
              );
              if (picked != null) onDateChanged(picked);
            } else {
              final picked = await showDialog<DateTime>(
                context: context,
                builder: (ctx) => CustomDatePickerDialog(
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                ),
              );
              if (picked != null) onDateChanged(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF21262D) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fmt.format(selectedDate),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.edit_calendar_outlined,
                  size: 16,
                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "FORMAT",
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF21262D) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            children: [
              _buildFormatPill('xlsx', 'XLS', isDark),
              _buildFormatPill('csv', 'CSV', isDark),
              _buildFormatPill('pdf', 'PDF', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatPill(String format, String label, bool isDark) {
    final isSelected = selectedFormat == format;

    return Expanded(
      child: GestureDetector(
        onTap: () => onFormatChanged(format),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF6366F1) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF6366F1))
                    : (isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// [mod:2026-02-26T11:30:00+05:30]
