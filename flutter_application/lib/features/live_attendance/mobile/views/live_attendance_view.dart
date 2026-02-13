import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_date_picker.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../dashboard/tablet/widgets/stat_card.dart';
import '../../../employees/services/employee_service.dart';
import '../../../employees/models/employee_model.dart';
import '../../../attendance/services/attendance_service.dart';
import '../../../attendance/models/attendance_record.dart';
import '../../../attendance/models/live_attendance_item.dart';
import '../../../attendance/admin/views/admin_correction_requests.dart';

class MobileLiveAttendanceContent extends StatefulWidget {
  const MobileLiveAttendanceContent({super.key});

  @override
  State<MobileLiveAttendanceContent> createState() => _MobileLiveAttendanceContentState();
}

class _MobileLiveAttendanceContentState extends State<MobileLiveAttendanceContent> with SingleTickerProviderStateMixin {
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
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: _buildTabs(context),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Live Dashboard
          _buildLiveDashboard(context),
          
          // Tab 2: Correction Requests
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AdminCorrectionRequests(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        labelColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA),
        unselectedLabelColor: Colors.grey[600],
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_view, size: 16),
                SizedBox(width: 8),
                Text('Dashboard'),
              ],
            ),
          ), 
            Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_late, size: 16),
                const SizedBox(width: 8),
                const Text('Requests'),
                // Dynamic Badge
                if (_pendingRequestsCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(), 
      children: [
        // Date Selector
        _buildDateSelector(context),
        const SizedBox(height: 0), 

        // 1. KPIs (2x2 Grid)
        _buildKPIGrid(),
        const SizedBox(height: 4), // Reduced from 12

        // 2. Filters & Search 
        _buildFilters(context),
        const SizedBox(height: 2), // Reduced from 8

        // 3. Real-time Monitoring List 
        _buildMonitoringList(context),
      ],
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: 12,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today, 
                  size: 14, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Theme.of(context).primaryColor
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, dd MMM').format(_selectedDate),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIGrid() {
    final totalEmployees = _items.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, 
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
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
          title: 'Late',
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
          contextText: 'Currently Clocked In',
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
                ? Colors.white.withOpacity(0.05) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.1) 
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
        // Dropdown
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.05) 
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white.withOpacity(0.1) 
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
          child: Text('No attendance records found.', style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
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
      onTap: () => _showEmployeeSessionsBottomSheet(context, item),
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
                        item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        item.designation,
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
                _buildMetricItem(context, 'Shift', item.user.shift ?? 'Gen'),
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
      return DateFormat('hh:mm').format(dt); // Short format for mobile
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

  void _showEmployeeSessionsBottomSheet(BuildContext context, LiveAttendanceItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle for aesthetics
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Header: User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: item.user.profileImage != null && item.user.profileImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CachedNetworkImage(
                            imageUrl: item.user.profileImage!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                              style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            errorWidget: (context, url, error) => Text(
                              item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                              style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        )
                      : Text(
                          item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                          style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(item.designation, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              "Daily Sessions (${DateFormat('dd MMM').format(_selectedDate)})",
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Sessions List (Timeline style)
            Expanded(
              child: item.records.isEmpty 
                ? const Center(child: Text("No sessions found"))
                : ListView.separated(
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
    );
  }

  Widget _buildSessionTimelineItem(BuildContext context, AttendanceRecord record, int sessionNum) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session Number / Counter
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF5B60F6).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF5B60F6).withOpacity(0.3)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "$sessionNum",
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF5B60F6)),
                ),
              ),
            ),
            if (sessionNum < 10) // Small visual line if needed
              Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 16),
        
        // Session Details
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
               _buildLocationRow(context, Icons.location_on_outlined, record.timeInAddress ?? 'No check-in address'),
               if (record.timeOut != null)
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: _buildLocationRow(context, Icons.logout_outlined, record.timeOutAddress ?? 'No check-out address'),
                 ),
                if (record.lateReason != null && record.lateReason!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 12, color: Colors.orange[800]),
                            const SizedBox(width: 6),
                            Text(
                              "Late Reason",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          record.lateReason!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
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
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: imageProvider, 
                  fit: BoxFit.cover
                ),
              ),
            ),
            placeholder: (context, url) => Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey.withOpacity(0.2),
              ),
              child: const Center(child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))),
            ),
            errorWidget: (context, url, error) => Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey.withOpacity(0.2),
              ),
              child: const Icon(Icons.broken_image, size: 16, color: Colors.grey),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
            Text(time, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRow(BuildContext context, IconData icon, String address) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            address, 
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey, height: 1.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
