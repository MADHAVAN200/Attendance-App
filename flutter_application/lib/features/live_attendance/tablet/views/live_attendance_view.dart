import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_date_picker.dart';
import '../../../../shared/services/auth_service.dart';
import 'package:flutter_application/features/dashboard/tablet/widgets/stat_card.dart';
import '../../../employees/services/employee_service.dart';
import '../../../employees/models/employee_model.dart';
import '../../../attendance/services/attendance_service.dart';
import '../../../attendance/models/attendance_record.dart';
import '../../../attendance/models/live_attendance_item.dart';
import '../../../attendance/admin/views/admin_correction_requests.dart';

class LiveAttendanceView extends StatefulWidget {
  const LiveAttendanceView({super.key});

  @override
  State<LiveAttendanceView> createState() => _LiveAttendanceViewState();
}

class _LiveAttendanceViewState extends State<LiveAttendanceView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data State
  DateTime _selectedDate = DateTime.now();
  List<LiveAttendanceItem> _items = [];
  bool _isLoading = false;
  
  // Cache
  final Map<String, List<LiveAttendanceItem>> _dashboardCache = {};
  
  // Stats
  int _present = 0;
  int _active = 0;
  int _absent = 0;
  int _late = 0;
  
  // Badge
  int _pendingRequestsCount = 0;

  late EmployeeService _employeeService;
  late AttendanceService _attendanceService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    _employeeService = EmployeeService(authService);
    _attendanceService = AttendanceService(authService.dio);
    
    _fetchDashboardData();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    if (!mounted) return;
    try {
      final requests = await _attendanceService.getCorrectionRequests(status: 'pending');
      if (mounted) {
        setState(() {
          _pendingRequestsCount = requests.length;
        });
      }
    } catch (e) {
      debugPrint("Error fetching pending requests: $e");
    }
  }

  Future<void> _fetchDashboardData({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Refresh badge count too
    _fetchPendingRequests();

    // 1. Check Cache
    if (!forceRefresh && _dashboardCache.containsKey(dateStr)) {
      _updateStateWithItems(_dashboardCache[dateStr]!);
      return;
    }
// ... (rest of _fetchDashboardData) 

    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _employeeService.getEmployees(),  
        _attendanceService.getAdminAttendanceRecords(dateStr)
      ]);

      final users = results[0] as List<Employee>;
      final records = results[1] as List<AttendanceRecord>;

      final merged = mergeAttendanceData(users, records);
      
      merged.sort((a, b) {
        if (a.status == "Absent" && b.status != "Absent") return 1;
        if (a.status != "Absent" && b.status == "Absent") return -1;
        return 0;
      });

      // 2. Update Cache
      _dashboardCache[dateStr] = merged;

      if (mounted) {
        _updateStateWithItems(merged);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateStateWithItems(List<LiveAttendanceItem> items) {
    setState(() {
      _items = items;
      _present = items.where((i) => i.status == "Present").length;
      _active = items.where((i) => i.status == "Active").length;
      _absent = items.where((i) => i.status == "Absent").length;
      _late = items.where((i) => i.isLate).length;
    });
  }

  List<LiveAttendanceItem> mergeAttendanceData(List<Employee> users, List<AttendanceRecord> records) {
    return users.map((user) {
      final userRecs = records.where((r) => r.userId == user.userId).toList();
      // Sort records by attendanceId to ensure latest is last
      userRecs.sort((a, b) => a.attendanceId.compareTo(b.attendanceId));
      return LiveAttendanceItem(user: user, records: userRecs);
    }).toList();
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
        // Tabs
        _buildTabs(context),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Live Dashboard
              _buildLiveDashboard(context),
              
              // Tab 2: Correction Requests
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: AdminCorrectionRequests(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 16), // Match MyAttendance margin
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF0F172A) // Match Dark Color
            : const Color(0xFFF1F5F9), // Match Light Color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.grey[300]!
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: isDark 
              ? const Color(0xFF334155) 
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: const Color(0xFF5B60F6), // Match Label Color
        unselectedLabelColor: isDark 
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B),
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_outlined, size: 16),
                SizedBox(width: 8),
                Text('Live Dashboard'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_late_outlined, size: 16),
                const SizedBox(width: 8),
                const Text('Correction Requests'),
                // Dynamic Badge
                if (_pendingRequestsCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_pendingRequestsCount',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDashboard(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          _buildDateSelector(context),
          const SizedBox(height: 16),
          
          // 1. KPIs
          _buildKPIGrid(),
          const SizedBox(height: 4), // Reduced from 12
          
          // 2. Filters 
          _buildFilters(context),
          const SizedBox(height: 2), // Reduced from 12

          // 3. List
          _buildMonitoringList(context),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => GlassDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                onDateSelected: (newDate) {
                  setState(() => _selectedDate = newDate);
                  _fetchDashboardData();
                },
              ),
            );
          },
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: 12,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today, 
                  size: 16, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Theme.of(context).primaryColor
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIGrid() {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final totalEmployees = _items.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isLandscape ? 4 : 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: isLandscape ? 2.0 : 2.4,
      children: [
        StatCard(
          title: 'Total Present',
          value: '$_present',
          total: '/ $totalEmployees',
          percentage: '',
          contextText: 'For Selected Date',
          isPositive: true,
          icon: Icons.people_alt,
          baseColor: const Color(0xFF5B60F6),
        ),
        StatCard(
          title: 'Late Arrivals',
          value: '$_late',
          total: '',
          percentage: '',
          contextText: 'Late Check-ins',
          isPositive: false,
          icon: Icons.access_time_filled,
          baseColor: const Color(0xFFF59E0B),
        ),
        StatCard(
          title: 'Absent',
          value: '$_absent',
          total: '',
          percentage: '',
          contextText: 'Not checked in',
          isPositive: false,
          icon: Icons.person_off,
          baseColor: const Color(0xFFEF4444),
        ),
        StatCard(
          title: 'Active Now',
          value: '$_active',
          total: '',
          percentage: '',
          contextText: 'Currently clocked in',
          isPositive: true,
          icon: Icons.coffee,
          baseColor: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      children: [
        // Search
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF1E2939) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey[300]!,
            ),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search employee...',
              prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        // Dropdown (Full width for easy touch)
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF1E2939) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: 'All Departments',
              icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodySmall?.color),
              dropdownColor: Theme.of(context).cardColor, 
              items: ['All Departments', 'Engineering', 'Design', 'Sales']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14))))
                  .toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonitoringList(BuildContext context) {
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No attendance records found for this date.', style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (c, i) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildMonitoringCard(context, item);
      },
    );
  }

  Widget _buildMonitoringCard(BuildContext context, LiveAttendanceItem item) {
    Color color;
    switch (item.statusLabel) {
      case "Active": color = Colors.blue; break;
      case "Late Active": color = Colors.blueAccent; break; 
      case "Present": color = Colors.green; break;
      case "Late": color = Colors.orange; break;
      default: color = Colors.grey;
    }
    final latest = item.latestRecord;
    final inTime = latest?.timeIn != null ? _formatTime(latest!.timeIn) : '--';
    final outTime = latest?.timeOut != null ? _formatTime(latest!.timeOut) : '--';

    return InkWell(
      onTap: () => _showEmployeeSessionsDialog(context, item),
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          children: [
            // Row 1: Profile + Status
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.1),
                  child: item.user.profileImage != null && item.user.profileImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: item.user.profileImage!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?', 
                              style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold),
                            ),
                            errorWidget: (context, url, error) => Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?', 
                              style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Text(
                          item.name.isNotEmpty ? item.name[0].toUpperCase() : '?', 
                          style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name, // Use userName from LiveAttendanceItem
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        "${item.designation} • ${item.department}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.5)),
            const SizedBox(height: 12),

            // Row 2: Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem(context, 'Time In', inTime),
                _buildMetricItem(context, 'Time Out', outTime),
                _buildMetricItem(context, 'Shift', item.user.shift ?? 'General'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '--';
    try {
      final dt = DateTime.parse(isoTime);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return ''; 
    }
  }

  Widget _buildMetricItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  void _showEmployeeSessionsDialog(BuildContext context, LiveAttendanceItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF5B60F6);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: GlassContainer(
            padding: const EdgeInsets.all(32),
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: item.user.profileImage != null && item.user.profileImage!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: CachedNetworkImage(
                                imageUrl: item.user.profileImage!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Text(
                                  item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                                  style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                                errorWidget: (context, url, error) => Text(
                                  item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                                  style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                              ),
                            )
                          : Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                              style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("${item.designation} • ${item.department}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                
                Text(
                  "Daily Sessions (${DateFormat('dd MMM yyyy').format(_selectedDate)})",
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                
                Flexible(
                  child: item.records.isEmpty 
                    ? const Center(child: Text("No records found"))
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: item.records.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 24),
                        itemBuilder: (context, index) {
                          final record = item.records[index];
                          return _buildSessionTimelineItem(context, record, index + 1);
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTimelineItem(BuildContext context, AttendanceRecord record, int sessionNum) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF5B60F6).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF5B60F6).withOpacity(0.3)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "$sessionNum",
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF5B60F6)),
                ),
              ),
            ),
            if (sessionNum < 10)
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeDetailColumn("Time In", _formatTime(record.timeIn), record.timeInImage),
                  _buildTimeDetailColumn("Time Out", _formatTime(record.timeOut), record.timeOutImage),
                ],
              ),
              const SizedBox(height: 12),
              _buildLocationRow(Icons.location_on_outlined, record.timeInAddress ?? 'No check-in address'),
              if (record.timeOut != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _buildLocationRow(Icons.logout_outlined, record.timeOutAddress ?? 'No check-out address'),
                ),
              if (record.lateReason != null && record.lateReason!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange[800]),
                          const SizedBox(width: 8),
                          Text(
                            "Late Reason",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.lateReason!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDetailColumn(String label, String time, String? imageUrl) {
    return Row(
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: imageProvider, 
                  fit: BoxFit.cover
                ),
              ),
            ),
            placeholder: (context, url) => Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.2),
              ),
              child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
            errorWidget: (context, url, error) => Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.2),
              ),
              child: const Icon(Icons.broken_image, size: 18, color: Colors.grey),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
            Text(time, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(IconData icon, String address) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address, 
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, height: 1.4),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
