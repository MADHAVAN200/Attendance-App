import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/report_service.dart';

class MobileReportsContent extends StatefulWidget {
  const MobileReportsContent({super.key});

  @override
  State<MobileReportsContent> createState() => _MobileReportsContentState();
}

class _MobileReportsContentState extends State<MobileReportsContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ReportService _reportService;

  // State
  String _selectedReportType = 'matrix_monthly';
  String _selectedFormat = 'xlsx';
  DateTime _selectedDate = DateTime.now();

  Map<String, dynamic>? _previewData;
  bool _isLoadingPreview = false;
  bool _isDownloading = false;

  final Map<String, String> _reportTypes = {
    'matrix_daily': 'Daily Matrix',
    'matrix_weekly': 'Weekly Matrix',
    'matrix_monthly': 'Monthly Matrix',
    'lateness_report': 'Lateness Report',
    'attendance_detailed': 'Detailed Log',
    'attendance_summary': 'Monthly Summary',
    'employee_master': 'Employee Master'
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize Service
    final authService = Provider.of<AuthService>(context, listen: false);
    _reportService = ReportService(authService.dio);
    
    _fetchPreview();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _requiresMonth => [
    'matrix_monthly', 'lateness_report', 'attendance_detailed', 'attendance_summary'
  ].contains(_selectedReportType);

  bool get _requiresDate => ['matrix_daily', 'matrix_weekly'].contains(_selectedReportType);

  String _fmtMonth(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}";
  String _fmtDate(DateTime d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  String _displayMonth(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[d.month-1]} ${d.year}";
  }

  Future<void> _fetchPreview() async {
    setState(() => _isLoadingPreview = true);
    try {
      final data = await _reportService.getPreview(
        type: _selectedReportType,
        month: _requiresMonth ? _fmtMonth(_selectedDate) : null,
        date: _requiresDate ? _fmtDate(_selectedDate) : null,
      );
      if (mounted) setState(() => _previewData = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Preview Failed: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingPreview = false);
    }
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    try {
      final path = await _reportService.downloadReport(
        type: _selectedReportType,
        format: _selectedFormat,
        month: _requiresMonth ? _fmtMonth(_selectedDate) : null,
        date: _requiresDate ? _fmtDate(_selectedDate) : null,
      );
      
      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Report Saved: $path"), action: SnackBarAction(label: "Open", onPressed: () {
             OpenFilex.open(path);
           }))
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download Failed: $e")));
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: _requiresMonth ? "SELECT MONTH (Pick any day)" : "SELECT DATE",
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchPreview();
    }
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

        // Tab Content
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
          // 1. Select Month/Date
          if (_requiresMonth || _requiresDate) ...[
            Text(
              _requiresMonth ? 'SELECT MONTH' : 'SELECT DATE',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
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
                        _requiresMonth ? _displayMonth(_selectedDate) : _fmtDate(_selectedDate),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                value: _reportTypes.containsKey(_selectedReportType) ? _selectedReportType : _reportTypes.keys.first,
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
                  if (newValue != null) {
                    setState(() {
                      _selectedReportType = newValue;
                    });
                    _fetchPreview();
                  }
                },
                items: _reportTypes.entries.map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value, overflow: TextOverflow.ellipsis),
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
              children: ['xlsx', 'csv', 'pdf'].map((format) {
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
                        format.toUpperCase(),
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
              onPressed: _isDownloading ? null : _handleDownload,
              icon: _isDownloading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.download, size: 20),
              label: Text(
                _isDownloading ? 'Downloading...' : 'Export Report', 
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
    if (_isLoadingPreview) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    
    if (_previewData == null || _previewData!['rows'] == null || (_previewData!['rows'] as List).isEmpty) {
      return Center(
         child: Padding(padding: const EdgeInsets.all(20), child: Text("No data available", style: GoogleFonts.poppins(color: Colors.grey)))
      );
    }

    final columns = _previewData!['columns'] as List;
    final rows = _previewData!['rows'] as List;

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
            columns: columns.map((c) => _buildColumnHeader(context, c.toString())).toList(),
            rows: rows.map((row) {
                 final cells = row as List;
                 return DataRow(
                   cells: cells.map((cell) => DataCell(
                     Text(
                       cell?.toString() ?? '-', 
                       style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color)
                     )
                   )).toList()
                 );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _buildColumnHeader(BuildContext context, String label) {
    return DataColumn(
      label: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildExportHistory(BuildContext context) {
     // Static Placeholder
    final history = [
      {'name': 'Attendance_Log.xlsx', 'date': 'Oct 25, 10:30 AM'},
      {'name': 'Monthly_Matrix.pdf', 'date': 'Sep 30, 06:00 PM'},
    ];

    return Column(
      children: history.map((e) => Padding(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e['name']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis),
                    Text(e['date']!, style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
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
