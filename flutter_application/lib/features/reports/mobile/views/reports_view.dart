import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class MobileReportsContent extends StatefulWidget {
  const MobileReportsContent({super.key});

  @override
  State<MobileReportsContent> createState() => _MobileReportsContentState();
}

class _MobileReportsContentState extends State<MobileReportsContent> with SingleTickerProviderStateMixin {
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // Top Configuration Card (Stacked for Mobile)
        _buildConfigurationCard(context),
        const SizedBox(height: 24),

        // Tabs
        _buildTabs(context),
        const SizedBox(height: 16),

        // Tab Content (Fixed Height or wrapped)
        // Since we are in a ListView, we can't use Expanded TabBarView easily without defined height.
        // We will use AnimatedBuilder or just a custom content switcher for simplicity in ListView.
        // Or we use the property `shrinkWrap: true` on TabBarView inside a Container with height?
        // Better: Just use AnimatedBuilder like we did for LiveAttendance.
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return _tabController.index == 0 
                ? _buildDataPreview(context)
                : _buildExportHistory(context);
          },
        ),
      ],
    );
  }

  Widget _buildConfigurationCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Select Month
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

          const SizedBox(height: 16),

          // 2. Report Type
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
                dropdownColor: Theme.of(context).cardColor,
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

          const SizedBox(height: 16),

          // 3. File Format
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
      
          const SizedBox(height: 24),

          // 4. Download Button
          SizedBox(
            height: 48,
            width: double.infinity, 
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 20), 
              label: Text(
                'Export Report', 
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
    );
  }

  Widget _buildTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44, // Slightly shorter for mobile
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
          Tab(text: 'Preview'), // Shortened text
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildDataPreview(BuildContext context) {
    // SingleChildScrollView for horizontal scrolling of DataTable
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20, 
            horizontalMargin: 16,
            headingRowColor: MaterialStateProperty.all(Colors.transparent),
            dataRowMaxHeight: 60,
            columns: [
              _buildColumnHeader(context, 'DATE'),
              _buildColumnHeader(context, 'EMPLOYEE'),
              _buildColumnHeader(context, 'SHIFT'),
              _buildColumnHeader(context, 'HOURS'),
              const DataColumn(label: Text('STATUS')), // Left aligned for scrolling table usually better or standard
            ],
            rows: [
              _buildDataRow(context, 'Oct 24', 'Sarah Wilson', '09:00 - 18:00', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 24', 'Mike Johnson', '09:00 - 18:00', '9h 00m', 'Late', Colors.orange),
              _buildDataRow(context, 'Oct 24', 'Anna Davis', '09:00 - 18:00', '0', 'Absent', Colors.red),
              _buildDataRow(context, 'Oct 24', 'James Wilson', '10:00 - 19:00', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 24', 'Lisa Brown', '09:00 - 18:00', '9h 00m', 'Present', Colors.green),
              _buildDataRow(context, 'Oct 23', 'Sarah Wilson', '09:00 - 18:00', '9h 00m', 'Present', Colors.green),
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
            ],
          ),
        ),
        DataCell(Text(shift, style: GoogleFonts.poppins(color: subColor, fontSize: 12))),
        DataCell(Text(hours, style: GoogleFonts.poppins(color: textColor, fontSize: 12, fontWeight: FontWeight.w500))),
        DataCell(
          Container(
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
      ],
    );
  }

  Widget _buildExportHistory(BuildContext context) {
    return Column(
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
              const SizedBox(width: 12), // Reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance_Log.xlsx', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis),
                    Text('Oct 25, 10:30 AM', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.download, size: 20, color: Colors.grey), onPressed: (){}),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
