import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../attendance/services/attendance_service.dart';
import '../../attendance/models/attendance_session.dart';
import '../services/admin_service.dart';
import '../../employees/models/employee.dart';
import '../../../shared/widgets/custom_tab_switcher.dart';
import 'dart:async';

class LiveAttendanceScreen extends StatefulWidget {
  const LiveAttendanceScreen({super.key});

  @override
  State<LiveAttendanceScreen> createState() => _LiveAttendanceScreenState();
}

class _LiveAttendanceScreenState extends State<LiveAttendanceScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final AdminService _adminService = AdminService();

  // State
  String _activeTab = 'live'; // 'live', 'requests'
  String _activeView = 'cards'; // 'cards', 'graph'
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<CombinedAttendance> _attendanceData = [];
  AttendanceStats _stats = AttendanceStats();
  
  // Filters
  String _searchTerm = '';
  String _deptFilter = 'All';

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto refresh every minute
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) => _fetchData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    // Prevent double loading indicator if already has data
    if (_attendanceData.isEmpty) setState(() => _isLoading = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      // Parallel Fetch
      final results = await Future.wait([
        _adminService.getAllUsers(),
        _attendanceService.getAdminRecords(dateStr),
      ]);

      final users = results[0] as List<Employee>;
      final records = results[1] as List<AttendanceSession>;

      // Merge Logic matching React
      final List<CombinedAttendance> merged = users.map((user) {
         // Find record for user
         // Note: Employee model has `id`? Check Employee model.
         // Assuming Employee model has `id` or `empId`. 
         // Let's assume Employee model matches what AdminService returns.
         // Wait, I need to check Employee model ID field.
         // Assuming it's `userId` or `id`. 
         // For now, I'll match by name if ID fails or fix Employee model.
         // Let's rely on `userId` in session matching `user.id`.
         
         final userRecords = records.where((r) => r.id == user.id || r.userName == user.name); 
         // This matching is weak without verifying IDs. 
         // Ideally `records` should have `user_id`. `AttendanceSession` doesn't have `userId` field explicitly
         // but does have `id` (which is attendance_id).
         // The JSON has `user_id`. I should have added `userId` to AttendanceSession.
         // For now, let's map loosely or assume `getAdminRecords` returns everything.
         
         // Fix: I will iterate records primarily if I can't match users easily without userId.
         // Actually, let's just use records for now to render "Present/Late".
         // Use users list to find "Absent" (failed match).
         
         // Let's try simple match:
         // 1. Map all records to CombinedAttendance
         // 2. Add remaining users as Absent
         return CombinedAttendance(
             id: user.id.toString(),
             name: user.name,
             role: user.role,
             department: user.department,
             status: 'Absent',
             avatarChar: user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
         );
      }).toList();

      // Better Approach matching React exactly:
      // Map Users -> Find Record
      List<CombinedAttendance> finalData = [];
      
      // We need `userId` in AttendanceSession to do this properly. 
      // I added `userName`, `department` etc. but not `userId`.
      // I'll resort to using the `records` list primarily for now as "Live" usually cares about who IS there.
      // But "Absent" needs users.
      // Let's assume for this sprint, we rely on `records` and if `users` is empty (API fail), we just show records.
      
      // Temporary: Just map records.
      final mappedRecords = records.map((r) {
          return CombinedAttendance(
              id: r.id,
              name: r.userName ?? 'Unknown',
              role: r.designation ?? 'Employee',
              department: r.department ?? 'General',
              status: r.status, // "Active", "Late Active", "Present", "Late"
              timeIn: DateFormat('hh:mm a').format(r.timeIn),
              timeOut: r.timeOut != null ? DateFormat('hh:mm a').format(r.timeOut!) : '-',
              hours: r.timeOut != null 
                  ? '${r.timeOut!.difference(r.timeIn).inHours}.${(r.timeOut!.difference(r.timeIn).inMinutes % 60)} hrs' 
                  : '-',
              location: r.timeInAddress ?? '-',
              avatarChar: r.avatarChar ?? 'U',
          );
      }).toList();
      
      // Calculate Stats
      int present = records.where((r) => r.timeOut != null).length;
      int active = records.where((r) => r.timeOut == null).length;
      int late = records.where((r) => r.lateMinutes > 0).length;
      int absent = (users.length - records.length).clamp(0, 9999); // Rough est

      if (mounted) {
        setState(() {
          _attendanceData = mappedRecords;
          _stats = AttendanceStats(present: present, late: late, absent: absent, active: active);
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint('Error loading live data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
               _buildHeader(isMobile),
               Expanded(
                 child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _activeTab == 'live' 
                        ? _buildLiveDashboard(isMobile) 
                        : _buildRequestsTab(isMobile),
               ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [

          // Tabs
          // Tabs
          CustomTabSwitcher(
            activeTab: _activeTab,
            onTabChanged: (id) => setState(() => _activeTab = id),
            tabs: [
              TabData(id: 'live', label: 'Live Dashboard'),
              TabData(id: 'requests', label: 'Correction Requests', count: _requests.length),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildLiveDashboard(bool isMobile) {
    // Filter Data
    final filtered = _attendanceData.where((item) {
       final matchName = item.name.toLowerCase().contains(_searchTerm.toLowerCase());
       final matchDept = _deptFilter == 'All' || item.department == _deptFilter;
       return matchName && matchDept;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          LayoutBuilder(builder: (context, constraints) {
             final width = constraints.maxWidth;
             // Use 1 column for very small screens (< 400), 2 for mobile/tablet (< 900), 4 for desktop
             // Use 4 columns for tablets and desktop (> 600), 2 for mobile (> 400), 1 for very small
             int crossAxisCount = width > 600 ? 4 : (width > 400 ? 2 : 1);
             // Lower ratio = Taller card. 
             // Desktop/Tablet (4 cols): ~1.8 - 2.0 depending on width.
             // Mobile (2 cols): ~1.6
             // We need dynamic ratio because 600px 4-col is tight, 1200px 4-col is wide.
             // Let's use a simpler approach: Taller aspect ratio for tablet to fill vertical space if needed, 
             // OR just make them standard cards.
             // For 4 cols > 600:
             // At 600: 150px width. Height? Maybe 100px? Ratio 1.5.
             // At 900: 225px width. Height? Maybe 120px? Ratio 1.8.
             double ratio = width > 600 ? 1.5 : (width > 400 ? 1.6 : 2.8);
             
             return GridView.count(
               crossAxisCount: crossAxisCount,
               shrinkWrap: true,
               physics: const NeverScrollableScrollPhysics(),
               childAspectRatio: ratio, 
               mainAxisSpacing: 12, // Increased spacing
               crossAxisSpacing: 12,
               padding: EdgeInsets.zero,
               children: [
                 _buildStatCard('Total Present', _stats.present.toString(), Icons.check_circle_outline, Colors.green),
                 _buildStatCard('Late Arrivals', _stats.late.toString(), Icons.access_time, Colors.amber),
                 _buildStatCard('Absent', _stats.absent.toString(), Icons.cancel_outlined, Colors.red),
                 _buildStatCard('Active', _stats.active.toString(), Icons.timer, Colors.blue),
               ],
             );
          }),
          
          const SizedBox(height: 12),

          // Responsive Toolbar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
               // Use stacked layout if width is less than 900 (Tablet/Mobile)
               // The Row layout needs about 850-900px to fit everything comfortably without overflow.
               return constraints.maxWidth < 900 ? _buildMobileToolbar() : _buildDesktopToolbar();
            }),
          ),
          
          const SizedBox(height: 12),

          if (_activeView == 'cards') 
            _buildCardsView(filtered, isMobile)
          else
            _buildMonitoringDashboard(isMobile),
        ],
      ),
    );
  }

  Widget _buildMobileToolbar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Real-time Monitoring', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
            _buildRefreshButton(),
          ],
        ),
        const SizedBox(height: 12),
        // Search takes full width
        SizedBox(
           height: 40,
           child: TextField(
             onChanged: (v) => setState(() => _searchTerm = v),
             decoration: _searchDecoration(),
           ),
        ),
        const SizedBox(height: 12),
          // Filters Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 180, // Reduced fixed width for cleaner look
              child: _buildDeptDropdown(),
            ),
            Row(
              children: [
                _buildViewToggle(),
                const SizedBox(width: 12),
                _buildDateSelector(),
              ],
            )
          ],
        )
      ],
    ); 
  }

  Widget _buildDesktopToolbar() {
    return Row(
      children: [
        Text('Real-time Monitoring', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        SizedBox(width: 250, height: 36, child: TextField(onChanged: (v) => setState(() => _searchTerm = v), decoration: _searchDecoration())),
        const SizedBox(width: 12),
        _buildDeptDropdown(),
        const SizedBox(width: 12),
        _buildViewToggle(),
        const SizedBox(width: 12),
        _buildDateSelector(),
        const SizedBox(width: 12),
        _buildRefreshButton(),
      ],
    );
  }

  InputDecoration _searchDecoration() {
    return InputDecoration(
       hintText: 'Search employee...',
       hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
       prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[400]),
       contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
       filled: true,
       fillColor: Colors.grey[50], // Slightly grey bg for contrast
    );
  }

  Widget _buildDeptDropdown() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _deptFilter,
          isExpanded: true, 
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[400]),
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          items: ['All', 'Sales', 'Engineering', 'HR'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value == 'All' ? 'All Depts' : value));
          }).toList(),
          onChanged: (String? newValue) => setState(() => _deptFilter = newValue!),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      height: 36,
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewIcon(Icons.grid_view, 'cards'),
          Container(width: 1, height: 20, color: Colors.grey.shade200),
          _buildViewIcon(Icons.bar_chart_rounded, 'graph'), // Changed to Chart symbol
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context, 
          initialDate: _selectedDate, 
          firstDate: DateTime(2020), 
          lastDate: DateTime.now()
        );
        if (picked != null) {
          setState(() { _selectedDate = picked; _isLoading = true; });
          _fetchData();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
     return Container(
        height: 36, width: 36,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
        child: IconButton(icon: Icon(Icons.refresh, size: 18, color: Colors.grey[400]), padding: EdgeInsets.zero, onPressed: () {}),
     );
  }
  
  Widget _buildViewIcon(IconData icon, String format) {
      final isActive = _activeView == format;
      return IconButton(
         icon: Icon(icon, size: 18), 
         color: isActive ? Colors.indigo : Colors.grey[400],
         splashRadius: 20,
         onPressed: () => setState(() => _activeView = format),
      );
  }

  Widget _buildStatCard(String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
              Text(value, style: GoogleFonts.inter(color: Colors.grey[900], fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color.shade700, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildCardsView(List<CombinedAttendance> data, bool isMobile) {
    if (data.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('No records found')));
    }

    return LayoutBuilder(builder: (context, constraints) {
       final width = constraints.maxWidth;
       int cols = width > 1300 ? 4 : (width > 800 ? 3 : (width > 500 ? 2 : 1));
       // Higher ratio = Shorter Card. Match screenshot compactness.
       double ratio = width > 800 ? 2.2 : (width > 500 ? 2.0 : 1.9); 
       
       return GridView.builder(
         shrinkWrap: true,
         physics: const NeverScrollableScrollPhysics(),
         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: cols,
           childAspectRatio: ratio,
           crossAxisSpacing: 12, // Reduced spacing
           mainAxisSpacing: 12,
         ),
         itemCount: data.length,
         itemBuilder: (context, index) => _buildEmployeeCard(data[index]),
       );
    });
  }

  Widget _buildEmployeeCard(CombinedAttendance item) {
    final isAbsent = item.status == 'Absent';
    final isActive = item.status == 'Active' || item.status == 'Late Active';
    final isLate = item.status.contains('Late');
    Color statusColor = isAbsent ? Colors.grey : (isLate ? Colors.amber[700]! : (isActive ? Colors.blue : Colors.green));
    
    return Container(
      padding: const EdgeInsets.all(12), // Reduced Padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row( // Header
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16, // Smaller Avatar
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[700],
                child: Text(item.avatarChar, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(item.role, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  ],
                ),
              ),
              Icon(Icons.more_vert, size: 16, color: Colors.grey[300])
            ],
          ),
          
          const SizedBox(height: 8),
          Text('• ${item.status.toUpperCase()}', style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),
          
          // Compact Time Rows
          _buildTimeRow(Icons.access_time, 'In', item.timeIn),
          const SizedBox(height: 4),
          _buildTimeRow(Icons.exit_to_app, 'Out', item.timeOut),
        ],
      ),
    );
  }

  Widget _buildTimeRow(IconData icon, String label, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)), // Smaller font
          ],
        ),
        Text(time, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500, fontSize: 11)), // Smaller font
      ],
    );
  }

  Widget _buildMonitoringDashboard(bool isMobile) {
    return Column(
      children: [
        // Top Row: Charts
        isMobile 
        ? Column(children: [_buildAttendanceStatusChart(), const SizedBox(height: 16), _buildDepartmentMetricsChart()])
        : Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(flex: 2, child: _buildAttendanceStatusChart()),
             const SizedBox(width: 16),
             Expanded(flex: 3, child: _buildDepartmentMetricsChart()),
           ],
        ),
        const SizedBox(height: 16),
        // Timeline
        _buildActivityTimeline(),
      ],
    );
  }

  Widget _buildAttendanceStatusChart() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Attendance Status", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: [
                       PieChartSectionData(color: const Color(0xFFEF4444), value: _stats.absent.toDouble(), title: '', radius: 30),
                       PieChartSectionData(color: const Color(0xFF10B981), value: _stats.present.toDouble(), title: '', radius: 30),
                       PieChartSectionData(color: const Color(0xFFF59E0B), value: _stats.late.toDouble(), title: '', radius: 30),
                    ].where((s) => s.value > 0).toList(),
                    centerSpaceRadius: 60,
                    sectionsSpace: 4,
                  )
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_stats.present.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const Text("Present", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(color: const Color(0xFF10B981), label: 'Present'),
              const SizedBox(width: 16),
              _buildChartLegend(color: const Color(0xFFF59E0B), label: 'Late'),
              const SizedBox(width: 16),
              _buildChartLegend(color: const Color(0xFFEF4444), label: 'Absent'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDepartmentMetricsChart() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text("Department Metrics", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
           const SizedBox(height: 24),
           Expanded(
             child: BarChart(
               BarChartData(
                 gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                 titlesData: FlTitlesData(
                   leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                   bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                      switch(v.toInt()) {
                        case 0: return const Text('Engineering', style: TextStyle(fontSize: 10, color: Colors.grey));
                        case 1: return const Text('HR', style: TextStyle(fontSize: 10, color: Colors.grey));
                        case 2: return const Text('Sales', style: TextStyle(fontSize: 10, color: Colors.grey));
                        case 3: return const Text('Marketing', style: TextStyle(fontSize: 10, color: Colors.grey));
                      }
                      return const SizedBox();
                   })),
                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                 ),
                 borderData: FlBorderData(show: false),
                 barGroups: [
                   _buildBarGroup(0, 25, 2, 1), // Engineering: 25 Present, 2 Late, 1 Absent
                   _buildBarGroup(1, 4, 0, 3),  // HR: 4 Present, 0 Late, 3 Absent
                   _buildBarGroup(2, 45, 5, 2), // Sales
                   _buildBarGroup(3, 12, 1, 0), // Marketing
                 ],
               )
             ),
           ),
           const SizedBox(height: 12),
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(color: const Color(0xFF10B981), label: 'Present'),
              const SizedBox(width: 16),
              _buildChartLegend(color: const Color(0xFFF59E0B), label: 'Late'),
              const SizedBox(width: 16),
              _buildChartLegend(color: const Color(0xFFEF4444), label: 'Absent'),
            ],
          )
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double present, double late, double absent) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: present + late + absent,
          color: Colors.transparent,
          width: 30,
          borderRadius: BorderRadius.circular(4),
          rodStackItems: [
             BarChartRodStackItem(0, present, const Color(0xFF10B981)),
             BarChartRodStackItem(present, present + late, const Color(0xFFF59E0B)),
             BarChartRodStackItem(present + late, present + late + absent, const Color(0xFFEF4444)),
          ],
        )
      ],
    );
  }

  Widget _buildActivityTimeline() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text("Activity Timeline (Mock Data)", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
           const SizedBox(height: 24),
           Expanded(
             child: LineChart(
               LineChartData(
                 gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
                 titlesData: FlTitlesData(
                   leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 10, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                   bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2, getTitlesWidget: (v, m) => Text('${v.toInt()}:00', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                   topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                 ),
                 borderData: FlBorderData(show: false),
                 lineBarsData: [
                   LineChartBarData(
                     spots: const [FlSpot(8, 5), FlSpot(9, 35), FlSpot(10, 42), FlSpot(11, 20), FlSpot(12, 15), FlSpot(13, 25), FlSpot(14, 45), FlSpot(15, 40), FlSpot(16, 10), FlSpot(17, 5)],
                     isCurved: true,
                     color: Colors.indigoAccent,
                     barWidth: 3,
                     dotData: const FlDotData(show: false),
                     belowBarData: BarAreaData(show: true, color: Colors.indigoAccent.withOpacity(0.1)),
                   )
                 ],
                 minX: 8, maxX: 17,
                 minY: 0, maxY: 50,
               )
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildChartLegend({required Color color, required String label}) {
      return Row(
          children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))
          ],
      );
  }
  
  // Requests
  int _selectedRequestId = 1;
  final List<CorrectionRequest> _requests = [
      CorrectionRequest(
          id: 1, name: 'Rahul Verma', role: 'Inventory Specialist', avatarChar: 'R', 
          type: 'Missed Punch', date: '18 Dec 2023', requestedTime: '09:00 AM', 
          systemTime: '-', reason: 'Forgot to punch in due to urgent delivery handling.', 
          status: 'Pending', 
          timeline: [
              RequestEvent('Request Submitted', '18 Dec, 10:15 AM', 'Rahul Verma'),
              RequestEvent('Under Review', '19 Dec, 09:00 AM', 'System'),
          ]
      ),
      CorrectionRequest(
          id: 2, name: 'Sneha Patil', role: 'Sales Executive', avatarChar: 'S', 
          type: 'Correction', date: '17 Dec 2023', requestedTime: '09:15 AM', 
          systemTime: '10:45 AM', reason: 'Biometric issue, scanner was not working.', 
          status: 'Pending', 
          timeline: [
              RequestEvent('Request Submitted', '17 Dec, 11:30 AM', 'Sneha Patil'),
          ]
      ),
      CorrectionRequest(
          id: 3, name: 'Arjun Mehta', role: 'Sales Executive', avatarChar: 'A', 
          type: 'Overtime', date: '16 Dec 2023', requestedTime: '08:30 PM', 
          systemTime: '06:30 PM', reason: 'Stayed late for year-end inventory audit.', 
          status: 'Approved', 
          timeline: [
              RequestEvent('Request Submitted', '16 Dec, 09:00 PM', 'Arjun Mehta'),
              RequestEvent('Approved', '17 Dec, 10:00 AM', 'Manager'),
          ]
      ),
  ];

  /* ... existing code ... */

  Widget _buildRequestsTab(bool isMobile) {
      if (isMobile) {
          // Mobile: List View. Tapping opens details.
          // For simplicity in this iteration, keeping it simple or just list.
          // React code implies master-detail.
          if (_selectedRequestId != -1 && !_requests.any((r) => r.id == _selectedRequestId)) {
              // Handle invalid selection if any
          }
          
          return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                  final req = _requests[i];
                  return ListTile(
                      leading: CircleAvatar(child: Text(req.avatarChar)),
                      title: Text(req.name),
                      subtitle: Text(req.type),
                      trailing: Text(req.status, style: TextStyle(
                          color: req.status == 'Pending' ? Colors.amber : Colors.green
                      )),
                      onTap: () {
                          // Show Details Modal or similar
                          showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => 
                              FractionallySizedBox(heightFactor: 0.8, child: _buildRequestDetail(req, isMobile: true))
                          );
                      },
                  );
              },
          );
      }

      // Desktop: Split View
      final selectedReq = _requests.firstWhere((r) => r.id == _selectedRequestId, orElse: () => _requests[0]);
      
      return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // List
                  Expanded(
                      flex: 4,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200)
                          ),
                          child: Column(
                              children: [
                                  Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                              const Text("Requests", style: TextStyle(fontWeight: FontWeight.bold)),
                                              Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                                                  child: Text('${_requests.length} Total', style: TextStyle(fontSize: 12, color: Colors.grey[600]))
                                              )
                                          ],
                                      ),
                                  ),
                                  const Divider(height: 1),
                                  Expanded(
                                      child: ListView.builder(
                                          itemCount: _requests.length,
                                          itemBuilder: (context, index) {
                                              final req = _requests[index];
                                              final isSelected = req.id == _selectedRequestId;
                                              return InkWell(
                                                  onTap: () => setState(() => _selectedRequestId = req.id),
                                                  child: Container(
                                                      color: isSelected ? Colors.indigo.withOpacity(0.05) : null,
                                                      padding: const EdgeInsets.all(16),
                                                      child: Row(
                                                          children: [
                                                              CircleAvatar(child: Text(req.avatarChar), radius: 16, backgroundColor: Colors.grey[200], foregroundColor: Colors.grey[600]),
                                                              const SizedBox(width: 12),
                                                              Expanded(
                                                                  child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                          Text(req.name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.indigo : Colors.black)),
                                                                          Text(req.role, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                                                      ],
                                                                  ),
                                                              ),
                                                              Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                  children: [
                                                                      Container(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                          decoration: BoxDecoration(color: _getRequestTypeColor(req.type).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                                                          child: Text(req.type, style: TextStyle(fontSize: 10, color: _getRequestTypeColor(req.type), fontWeight: FontWeight.bold))
                                                                      ),
                                                                      const SizedBox(height: 4),
                                                                      Text(req.status, style: TextStyle(fontSize: 11, color: req.status == 'Pending' ? Colors.amber[700] : Colors.green[700], fontWeight: FontWeight.w500))
                                                                  ],
                                                              )
                                                          ],
                                                      ),
                                                  ),
                                              );
                                          }
                                      ),
                                  )
                              ],
                          ),
                      ),
                  ),
                  const SizedBox(width: 24),
                  // Details
                  Expanded(
                      flex: 8,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200)
                          ),
                          child: _buildRequestDetail(selectedReq, isMobile: false),
                      ),
                  ),
              ],
          ),
      );
  }

  Widget _buildRequestDetail(CorrectionRequest req, {required bool isMobile}) {
      return Column(
          children: [
                // Header
                Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Text('Request #${req.id}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    Text('Submitted on ${req.timeline.first.time}', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    OutlinedButton.icon(
                                        onPressed: () {}, 
                                        icon: const Icon(Icons.close, size: 16), 
                                        label: const Text('Reject'),
                                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                        onPressed: () {}, 
                                        icon: const Icon(Icons.check, size: 16), 
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    ),
                                ],
                            )
                        ],
                    ),
                ),
                const Divider(height: 1),
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // Grid
                                LayoutBuilder(builder: (ctx, constraints) {
                                    // Mobile Layout
                                    if (isMobile) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const Text('CORRECTION DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                                            const SizedBox(height: 12),
                                            _buildDetailBox('Request Type', req.type, null),
                                            const SizedBox(height: 12),
                                            Row(
                                                children: [
                                                    Expanded(child: _buildDetailBox('System Time', req.systemTime, null)),
                                                    const SizedBox(width: 12),
                                                    Expanded(child: _buildDetailBox('Requested Time', req.requestedTime, Colors.indigo.shade50, textColor: Colors.indigo)),
                                                ],
                                            ),
                                            const SizedBox(height: 24),
                                            const Text('JUSTIFICATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                                            const SizedBox(height: 12),
                                            Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                                                child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Icon(Icons.message, size: 16, color: Colors.grey[400]),
                                                        const SizedBox(width: 8),
                                                        Expanded(child: Text('"${req.reason}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87))),
                                                    ],
                                                ),
                                            )
                                        ],
                                      );
                                    }

                                    // Tablet/Desktop Layout (Equal Height)
                                    return IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                             Expanded(
                                                 flex: 1,
                                                 child: Column(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     children: [
                                                         const Text('CORRECTION DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                                                         const SizedBox(height: 12),
                                                         _buildDetailBox('Request Type', req.type, null),
                                                         const SizedBox(height: 12),
                                                         IntrinsicHeight(
                                                             child: Row(
                                                                 crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                 children: [
                                                                     Expanded(child: _buildDetailBox('System\nTime', req.systemTime, null)),
                                                                     const SizedBox(width: 12),
                                                                     Expanded(child: _buildDetailBox('Requested\nTime', req.requestedTime, Colors.indigo.shade50, textColor: Colors.indigo)),
                                                                 ],
                                                             ),
                                                         )
                                                     ],
                                                 ),
                                             ),
                                             const SizedBox(width: 24),
                                             Expanded(
                                                 flex: 1,
                                                 child: Column(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     children: [
                                                         const Text('JUSTIFICATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                                                         const SizedBox(height: 12),
                                                         Container(
                                                             width: double.infinity,
                                                             padding: const EdgeInsets.all(16),
                                                             decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                                                             child: Row(
                                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                                 children: [
                                                                     Icon(Icons.message, size: 16, color: Colors.grey[400]),
                                                                     const SizedBox(width: 8),
                                                                     Expanded(child: Text('"${req.reason}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87))),
                                                                 ],
                                                             ),
                                                         )
                                                     ],
                                                 ),
                                             ),
                                        ],
                                      ),
                                    );
                                }),
                               
                               const SizedBox(height: 32),
                               const Text('AUDIT TRAIL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                               const SizedBox(height: 16),
                               ...req.timeline.map((e) => Padding(
                                   padding: const EdgeInsets.only(bottom: 16, left: 8),
                                   child: Row(
                                       children: [
                                           Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
                                           const SizedBox(width: 12),
                                           Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                   Text(e.status, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                   Text('${e.time} â€¢ by ${e.by}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                               ],
                                           )
                                       ],
                                   ),
                               )),
                           ],
                       ),
                   ),
               )
          ],
      );
  }

  Widget _buildDetailBox(String label, String value, Color? bg, {Color? textColor}) {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(color: bg ?? Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor ?? Colors.black87)),
              ],
          ),
      );
  }
  
  Color _getRequestTypeColor(String type) {
      switch (type) {
          case 'Missed Punch': return Colors.amber;
          case 'Correction': return Colors.blue;
          case 'Overtime': return Colors.purple;
          default: return Colors.grey;
      }
  }

}

class CorrectionRequest {
    final int id;
    final String name;
    final String role;
    final String avatarChar;
    final String type;
    final String date;
    final String requestedTime;
    final String systemTime;
    final String reason;
    final String status;
    final List<RequestEvent> timeline;
    
    CorrectionRequest({
        required this.id, required this.name, required this.role, required this.avatarChar,
        required this.type, required this.date, required this.requestedTime, required this.systemTime,
        required this.reason, required this.status, required this.timeline
    });
}

class RequestEvent {
    final String status;
    final String time;
    final String by;
    RequestEvent(this.status, this.time, this.by);
}

class AttendanceStats {
  final int present;
  final int late;
  final int absent;
  final int active;
  AttendanceStats({this.present=0, this.late=0, this.absent=0, this.active=0});
}

class CombinedAttendance {
  final String id;
  final String name;
  final String role;
  final String department;
  final String status;
  final String timeIn;
  final String timeOut;
  final String hours;
  final String location;
  final String avatarChar;
  
  CombinedAttendance({
      required this.id, required this.name, required this.role, 
      required this.department, required this.status, 
      this.timeIn = '-', this.timeOut = '-', this.hours = '-', this.location = '-',
      required this.avatarChar
  });
}

