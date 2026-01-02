import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedReportType = 'Detailed Log';
  String _selectedMonth = 'October 2023';
  String _selectedFormat = 'Excel';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Configuration Card
        _buildConfigurationCard(context),
        const SizedBox(height: 24),

        // Tabs
        _buildTabs(context),
        const SizedBox(height: 24),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDataPreview(context),
              _buildExportHistory(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Row 1: Select Month & Report Type
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECT MONTH',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedMonth,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REPORT TYPE',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedReportType,
                          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).textTheme.bodySmall?.color),
                          isExpanded: true,
                          elevation: 16,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedReportType = newValue!;
                            });
                          },
                          items: <String>['Detailed Log', 'Overtime', 'Late Arrivals']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Row 2: File Format & Download
          Row(
            children: [
              // Segmented Control
              // Segmented Control
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FILE FORMAT',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: ['Excel', 'CSV', 'PDF'].map((format) {
                          final isSelected = _selectedFormat == format;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFormat = format),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? (isDark ? Colors.white.withOpacity(0.1) : Colors.white) 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isSelected && !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))] : null,
                                ),
                                child: Text(
                                  format,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected 
                                        ? Theme.of(context).textTheme.bodyLarge?.color 
                                        : Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Download Button
              Expanded(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      // Spacer to align with input label
                      Text(
                        ' ', // Non-breaking space for explicit height alignment
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ), 
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        width: double.infinity, // Fill full width of the column
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download, size: 20), // Slightly larger icon
                          label: Text(
                            'Export Report', // More descriptive
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                   ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
             if (isDark) BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Data Preview'),
          Tab(text: 'Export History'),
        ],
      ),
    );
  }

  Widget _buildDataPreview(BuildContext context) {
    // 5 Columns: Date, Employee, Shift, Work Hours, Status
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DataTable(
            columnSpacing: 12, // Tight spacing
            horizontalMargin: 16,
            headingRowColor: MaterialStateProperty.all(Colors.transparent),
            dataRowMaxHeight: 60,
            columns: [
              _buildColumnHeader(context, 'DATE'),
              _buildColumnHeader(context, 'EMPLOYEE'),
              _buildColumnHeader(context, 'SHIFT'),
              _buildColumnHeader(context, 'HOURS'),
              const DataColumn(label: Expanded(child: Text('STATUS', textAlign: TextAlign.right))), // Align Status right
            ],
            rows: [
              _buildDataRow(context, 'Oct 24', 'Sarah Wilson', '09:00 - 18:00', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 24', 'Mike Johnson', '09:00 - 18:00', '9h 00m', 'Late', Colors.orange),
              _buildDataRow(context, 'Oct 24', 'Anna Davis', '09:00 - 18:00', '0', 'Absent', Colors.red),
              _buildDataRow(context, 'Oct 24', 'James Wilson', '10:00 - 19:00', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 24', 'Lisa Brown', '09:00 - 18:00', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 23', 'Sarah Wilson', '09:00 - 18:00', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 23', 'Mike Johnson', '09:00 - 18:00', '8h 55m', 'Present', Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  DataColumn _buildColumnHeader(BuildContext context, String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, String date, String name, String shift, String hours, String status, Color color) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subColor = Theme.of(context).textTheme.bodySmall?.color;
    
    return DataRow(
      cells: [
        DataCell(Text(date, style: GoogleFonts.poppins(color: subColor, fontSize: 12))),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500, fontSize: 13)),
              // Optional: Add Role subtext if space
            ],
          ),
        ),
        DataCell(Text(shift, style: GoogleFonts.poppins(color: subColor, fontSize: 12))),
        DataCell(Text(hours, style: GoogleFonts.poppins(color: textColor, fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportHistory(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [1, 2, 3].map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.table_chart, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attendance_Log_Oct2023.xlsx', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      Text('Exported on Oct 25, 10:30 AM', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.download, size: 20, color: Colors.grey), onPressed: (){}),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}
