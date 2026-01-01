
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/custom_tab_switcher.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _activeTab = 'Data Preview';
  String _selectedReportType = 'Detailed Attendance Log';
  String _selectedFormat = 'Excel';
  
  // Mock Data for Data Preview
  final List<Map<String, dynamic>> _reportData = [
    {'date': '2023-12-01', 'id': 'EMP001', 'name': 'Arjun Mehta', 'dept': 'Sales', 'shift': 'General', 'in': '09:00 AM', 'out': '06:00 PM', 'hrs': '9h 00m', 'status': 'Present'},
    {'date': '2023-12-01', 'id': 'EMP002', 'name': 'Priya Sharma', 'dept': 'Retail', 'shift': 'Morning', 'in': '08:55 AM', 'out': '05:30 PM', 'hrs': '8h 35m', 'status': 'Present'},
    {'date': '2023-12-01', 'id': 'EMP003', 'name': 'Rahul Verma', 'dept': 'Logistics', 'shift': 'General', 'in': '10:15 AM', 'out': '06:00 PM', 'hrs': '7h 45m', 'status': 'Late'},
    {'date': '2023-12-02', 'id': 'EMP001', 'name': 'Arjun Mehta', 'dept': 'Sales', 'shift': 'General', 'in': '09:05 AM', 'out': '06:10 PM', 'hrs': '9h 05m', 'status': 'Present'},
    {'date': '2023-12-03', 'id': 'EMP001', 'name': 'Arjun Mehta', 'dept': 'Sales', 'shift': 'General', 'in': '09:00 AM', 'out': '06:00 PM', 'hrs': '9h 00m', 'status': 'Present'},
    {'date': '2023-12-03', 'id': 'EMP002', 'name': 'Priya Sharma', 'dept': 'Retail', 'shift': 'Morning', 'in': '09:00 AM', 'out': '05:30 PM', 'hrs': '8h 30m', 'status': 'Present'},
  ];

  // Mock Data for Export History
  final List<Map<String, dynamic>> _historyData = [
    {'name': 'Detailed Attendance', 'size': '1.2 MB', 'type': 'excel', 'date': '01 Dec 2023, 10:00 AM', 'status': 'Ready'},
    {'name': 'Payroll Summary', 'size': '450 KB', 'type': 'pdf', 'date': '01 Dec 2023, 10:05 AM', 'status': 'Ready'},
    {'name': 'Lateness Report', 'size': '200 KB', 'type': 'excel', 'date': '01 Nov 2023, 09:30 AM', 'status': 'Ready'},
    {'name': 'System Backup', 'size': '-', 'type': 'zip', 'date': '15 Jan 2023, 02:00 PM', 'status': 'Failed'},
  ];

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsive layout
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 1000; 

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // 1. Controls Section (Only show if Data Preview is active, or keep it? 
          // Screenshot shows Export History as a separate full card. 
          // I will toggle the ENTIRE content below title based on tab, or just the bottom part.
          // The Controls (Month/Type) apply to NEW reports. History is old. 
          // So I should probably Hide Controls `Container` when History is active, OR keep tabs above everything.
          // Current Tabs are BELOW controls. 
          // Screenshot shows "Export History" header inside the card.
          // I'll move Tabs to the TOP, or just swap the bottom container.
          // Let's swap the whole view structure to match: Tabs -> Content.
          
          // REFACTOR: Tabs on top?
          // The previous design had Controls -> Tabs -> Preview.
          // User request "do this in the export history section".
          // I will just switch the "Bottom Card" content if tab is History.
          // AND I should probably hide the "Generate Report" controls if History is open, as they aren't relevant to history?
          // I'll hide the Controls Container if `_activeTab == 'Export History'`.
          
          if (_activeTab == 'Data Preview') ...[
             Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: isMobile ? _buildMobileControls() : _buildDesktopControls(),
            ),
            const SizedBox(height: 24),
          ],

          // 2. Tabs
          CustomTabSwitcher(
            activeTab: _activeTab,
            onTabChanged: (id) => setState(() => _activeTab = id),
            tabs: [
              TabData(id: 'Data Preview', label: 'Data Preview'),
              TabData(id: 'Export History', label: 'Export History'),
            ],
          ),

          const SizedBox(height: 24),

          // 3. Content Area
          _activeTab == 'Data Preview' 
            ? _buildDataPreview(isMobile, width)
            : _buildExportHistory(isMobile, width),
        ],
      ),
    );
  }

  Widget _buildDataPreview(bool isMobile, double width) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_outlined, size: 20, color: Colors.indigo),
              const SizedBox(width: 8),
              Text('Report Preview', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(width: 8),
              Flexible(child: Text('(Sample data for attendance detailed log)', style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 24),
          
          isMobile 
            ? _buildMobileCardList() 
            : _buildDataTable(width),
          
          if (!isMobile) ...[
            const SizedBox(height: 16),
            Center(child: Text('This is a preview. Actual report will contain all records.', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)))
          ]
        ],
      ),
    );
  }

  Widget _buildExportHistory(bool isMobile, double width) {
     return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history, size: 20, color: Theme.of(context).iconTheme.color),
                  const SizedBox(width: 8),
                  Text('Export History', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
              Icon(Icons.filter_list, size: 20, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
          
          // Content
          isMobile 
          ? ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historyData.length,
              separatorBuilder: (c, i) => Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              itemBuilder: (context, index) => _buildHistoryItemMobile(_historyData[index]),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: width - 100),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Theme.of(context).scaffoldBackgroundColor),
                  headingTextStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color, letterSpacing: 0.5),
                  dataTextStyle: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                  columnSpacing: 24,
                  horizontalMargin: 24,
                  columns: const [
                    DataColumn(label: Text('FILE NAME')),
                    DataColumn(label: Text('GENERATED')),
                    DataColumn(label: Text('STATUS')),
                    DataColumn(label: Text('ACTION')),
                  ],
                  rows: _historyData.map((data) => _buildHistoryRow(data)).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  DataRow _buildHistoryRow(Map<String, dynamic> data) {
    bool isReady = data['status'] == 'Ready';
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            _buildFileIcon(data['type']),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data['name'], style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
                Text(data['size'], style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            )
          ],
        )),
        DataCell(Text(data['date'], style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color))),
        DataCell(Container(
           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
           decoration: BoxDecoration(color: (isReady ? Colors.green : Colors.red).withAlpha(26), borderRadius: BorderRadius.circular(20)),
           child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               Icon(isReady ? Icons.check_circle_outline : Icons.error_outline, size: 14, color: isReady ? Colors.green : Colors.red),
               const SizedBox(width: 4),
               Text(data['status'], style: TextStyle(fontSize: 12, color: isReady ? Colors.green : Colors.red, fontWeight: FontWeight.w500)),
             ],
           ),
        )),
        DataCell(Text('Download', style: TextStyle(color: isReady ? const Color(0xFF4338CA) : Theme.of(context).disabledColor, fontWeight: FontWeight.w600))),
      ]
    );
  }

  Widget _buildHistoryItemMobile(Map<String, dynamic> data) {
    bool isReady = data['status'] == 'Ready';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildFileIcon(data['type']),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'], 
                      style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(data['date'], style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(color: (isReady ? Colors.green : Colors.red).withAlpha(26), borderRadius: BorderRadius.circular(20)),
                 child: Text(data['status'], style: TextStyle(fontSize: 11, color: isReady ? Colors.green : Colors.red, fontWeight: FontWeight.w500)),
              ),
              if (isReady) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20, color: Color(0xFF4338CA)),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(String type) {
    Color color = type == 'pdf' ? Colors.red : (type == 'excel' ? Colors.green : Colors.blue);
    IconData icon = type == 'pdf' ? Icons.picture_as_pdf : (type == 'excel' ? Icons.table_view : Icons.folder_zip);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  // ... (controls methods unchanged) ... 

  // Fix _buildMobileCardList overflow
  Widget _buildMobileCardList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reportData.length,
      itemBuilder: (context, index) {
        final data = _reportData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                   CircleAvatar(radius: 16, backgroundColor: Colors.indigo.withOpacity(0.1), child: Text(data['name'][0], style: const TextStyle(fontSize: 12, color: Colors.indigo))),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(data['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis),
                         Text(data['id'], style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                       ],
                     ),
                   ),
                   const SizedBox(width: 8),
                   _buildStatusBadge(data['status']),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMobileStat('Date', data['date']),
                  _buildMobileStat('Shift', data['shift']),
                  _buildMobileStat('Dept', data['dept']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMobileStat('Time In', data['in']),
                  _buildMobileStat('Time Out', data['out']),
                  _buildMobileStat('Work Hrs', data['hrs']),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopControls() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildInputGroup('SELECT MONTH', _buildDateSelector())),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildInputGroup('REPORT TYPE', _buildDropdown())),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildInputGroup('FILE FORMAT', _buildFormatToggle())),
        const SizedBox(width: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputGroup('SELECT MONTH', _buildDateSelector()),
        const SizedBox(height: 16),
        _buildInputGroup('REPORT TYPE', _buildDropdown()),
        const SizedBox(height: 16),
        _buildInputGroup('FILE FORMAT', _buildFormatToggle()),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Download Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4338CA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInputGroup(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  DateTime _selectedReportDate = DateTime.now();

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedReportDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _selectedReportDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][_selectedReportDate.month - 1]}, ${_selectedReportDate.year}",
              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)
            ),
            Icon(Icons.calendar_today, size: 16, color: Theme.of(context).iconTheme.color),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedReportType,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).iconTheme.color),
          items: ['Detailed Attendance Log', 'Summary Report', 'Late Arrivals'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)))).toList(),
          onChanged: (v) => setState(() => _selectedReportType = v!),
        ),
      ),
    );
  }

  Widget _buildFormatToggle() {
    return Row(
      children: ['Excel', 'CSV', 'PDF'].map((format) {
         final isSelected = _selectedFormat == format;
         return Expanded(
           child: GestureDetector(
             onTap: () => setState(() => _selectedFormat = format),
             child: Container(
               height: 48,
               margin: const EdgeInsets.only(right: 8),
               decoration: BoxDecoration(
                 color: isSelected ? const Color(0xFFEEF2FF) : Theme.of(context).cardColor, 
                 border: Border.all(color: isSelected ? const Color(0xFF4338CA) : Theme.of(context).dividerColor.withOpacity(0.1)),
                 borderRadius: BorderRadius.circular(8),
               ),
               alignment: Alignment.center,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(
                     format == 'Excel' ? Icons.table_view : (format == 'PDF' ? Icons.picture_as_pdf : Icons.description), 
                     size: 16, 
                     color: isSelected ? const Color(0xFF4338CA) : Theme.of(context).disabledColor
                   ),
                   const SizedBox(width: 8),
                   Flexible(child: Text(format, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF4338CA) : Theme.of(context).textTheme.bodyMedium?.color), overflow: TextOverflow.ellipsis)),
                 ],
               ),
             ),
           ),
         );
      }).toList(),
    );
  }

  Widget _buildDataTable(double screenWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: screenWidth - 100), // Ensure full width
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Theme.of(context).scaffoldBackgroundColor),
          headingTextStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color, letterSpacing: 0.5),
          dataTextStyle: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
          columnSpacing: 24,
          horizontalMargin: 24,
          border: TableBorder(horizontalInside: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          columns: const [
            DataColumn(label: Text('DATE')),
            DataColumn(label: Text('EMPLOYEE ID')),
            DataColumn(label: Text('NAME')),
            DataColumn(label: Text('DEPARTMENT')),
            DataColumn(label: Text('SHIFT')),
            DataColumn(label: Text('TIME IN')),
            DataColumn(label: Text('TIME OUT')),
            DataColumn(label: Text('WORK HRS')),
            DataColumn(label: Text('STATUS')),
          ],
          rows: _reportData.map((data) {
             return DataRow(
               cells: [
                 DataCell(Text(data['date'])),
                 DataCell(Text(data['id'])),
                 DataCell(Row(children: [
                    CircleAvatar(radius: 12, backgroundColor: Colors.indigo.withOpacity(0.1), child: Text(data['name'][0], style: const TextStyle(fontSize: 10, color: Colors.indigo))),
                    const SizedBox(width: 8),
                    Text(data['name'])
                 ])),
                 DataCell(Text(data['dept'])),
                 DataCell(Text(data['shift'])),
                 DataCell(Text(data['in'])),
                 DataCell(Text(data['out'])),
                 DataCell(Text(data['hrs'])),
                 DataCell(_buildStatusBadge(data['status'])),
               ]
             );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Present' ? Colors.green : (status == 'Late' ? Colors.amber : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
