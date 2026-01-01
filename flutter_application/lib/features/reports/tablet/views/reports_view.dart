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
  String _selectedReportType = 'Detailed Attendance Log';
  String _selectedMonth = 'October 2023';

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
      margin: const EdgeInsets.fromLTRB(32, 32, 32, 0),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align inputs and buttons at the bottom
        children: [
          // Month Picker (Flexible)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT MONTH',
                  style: GoogleFonts.poppins(
                    fontSize: 12, // Standard Label
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedMonth,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Report Type (Flexible)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REPORT TYPE',
                  style: GoogleFonts.poppins(
                    fontSize: 12, // Standard Label
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReportType,
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true, // Ensure dropdown text truncates if needed
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
                      items: <String>['Detailed Attendance Log', 'Overtime Summary', 'Late Arrivals Report']
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
          const SizedBox(width: 16),

          // Format Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FILE FORMAT',
                style: GoogleFonts.poppins(
                  fontSize: 12, // Standard Label
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFormatButton(context, 'Excel', Icons.table_chart, const Color(0xFF1D6F42)),
                  const SizedBox(width: 8),
                  _buildFormatButton(context, 'CSV', Icons.description, Colors.blue),
                  const SizedBox(width: 8),
                  _buildFormatButton(context, 'PDF', Icons.picture_as_pdf, Colors.red),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Download Action
          Container(
            height: 48,
            alignment: Alignment.bottomCenter,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 18),
              label: Text(
                'Download Report',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B60F6), // Match image purple
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                fixedSize: const Size.fromHeight(48), // Match input height
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w500, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      height: 45,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Data Preview'),
          Tab(text: 'Export History'),
        ],
      ),
    );
  }

  Widget _buildDataPreview(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            headingTextStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            dataRowColor: MaterialStateProperty.all(Colors.transparent),
            columns: const [
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('EMP ID')),
              DataColumn(label: Text('NAME')),
              DataColumn(label: Text('DEPARTMENT')),
              DataColumn(label: Text('SHIFT')),
              DataColumn(label: Text('TIME IN')),
              DataColumn(label: Text('TIME OUT')),
              DataColumn(label: Text('WORK HRS')),
              DataColumn(label: Text('STATUS')),
            ],
            rows: [
              _buildDataRow(context, 'Oct 24, 2023', 'EMP001', 'Sarah Wilson', 'Design', '09:00 - 18:00', '09:00 AM', '06:00 PM', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 24, 2023', 'EMP002', 'Mike Johnson', 'Engineering', '09:00 - 18:00', '09:15 AM', '06:15 PM', '9h 00m', 'Late', Colors.orange),
              _buildDataRow(context, 'Oct 24, 2023', 'EMP003', 'Anna Davis', 'Marketing', '09:00 - 18:00', '--', '--', '--', 'Absent', Colors.red),
              _buildDataRow(context, 'Oct 24, 2023', 'EMP004', 'James Wilson', 'Sales', '10:00 - 19:00', '10:00 AM', '07:00 PM', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 24, 2023', 'EMP005', 'Lisa Brown', 'HR', '09:00 - 18:00', '08:55 AM', '05:55 PM', '9h 00m', 'Present', Colors.green),
            ],
          ),
        ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, String date, String id, String name, String dept, String shift, String timeIn, String timeOut, String hours, String status, Color color) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    return DataRow(
      cells: [
        DataCell(Text(date, style: GoogleFonts.poppins(color: textColor, fontSize: 13))),
        DataCell(Text(id, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500, fontSize: 13))),
        DataCell(Text(name, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500, fontSize: 13))),
        DataCell(Text(dept, style: GoogleFonts.poppins(color: textColor, fontSize: 13))),
        DataCell(Text(shift, style: GoogleFonts.poppins(color: textColor, fontSize: 13))),
        DataCell(Text(timeIn, style: GoogleFonts.poppins(color: textColor, fontSize: 13))),
        DataCell(Text(timeOut, style: GoogleFonts.poppins(color: textColor, fontSize: 13))),
        DataCell(Text(hours, style: GoogleFonts.poppins(color: textColor, fontSize: 13))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportHistory(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No export history found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
