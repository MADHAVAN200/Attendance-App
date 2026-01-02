import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../dashboard/tablet/widgets/stat_card.dart';
import 'correction_requests_view.dart'; // Mobile version

class MobileLiveAttendanceContent extends StatefulWidget {
  const MobileLiveAttendanceContent({super.key});

  @override
  State<MobileLiveAttendanceContent> createState() => _MobileLiveAttendanceContentState();
}

class _MobileLiveAttendanceContentState extends State<MobileLiveAttendanceContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
          const MobileCorrectionRequestsView(), 
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          boxShadow: isDark ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        labelColor: Colors.white, 
        unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4), 
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: [
          const Tab(text: 'Dashboard'), // Shortened text for mobile
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Requests'), // Shortened text
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red, 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '5',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      physics: const BouncingScrollPhysics(), // Optional, NestedScrollView might override or coordinate
      children: [
        // 1. KPIs (2x2 Grid)
        _buildKPIGrid(),
        const SizedBox(height: 12),

        // 2. Filters & Search 
        _buildFilters(context),
        const SizedBox(height: 12),

        // 3. Real-time Monitoring List 
        _buildMonitoringList(context),
      ],
    );
  }

  Widget _buildKPIGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, 
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3, // Taller cards for Mobile width to prevent overflow
      children: const [
        StatCard(
          title: 'Total Present',
          value: '142',
          total: '/ 150',
          percentage: '+5%',
          contextText: 'vs yst',
          isPositive: true,
          icon: Icons.people_alt,
          baseColor: Color(0xFF5B60F6),
        ),
        StatCard(
          title: 'Late',
          value: '12',
          total: '',
          percentage: '-2%',
          contextText: 'vs yst',
          isPositive: true,
          icon: Icons.access_time_filled,
          baseColor: Color(0xFFF59E0B),
        ),
        StatCard(
          title: 'Absent',
          value: '8',
          total: '',
          percentage: '+1%',
          contextText: 'vs yst',
          isPositive: false,
          icon: Icons.person_off,
          baseColor: Color(0xFFEF4444),
        ),
        StatCard(
          title: 'On Break',
          value: '45',
          total: '',
          percentage: '',
          contextText: 'Now',
          isPositive: true,
          icon: Icons.coffee,
          baseColor: Color(0xFF10B981),
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
    // Using dummy list data 
    final employees = [
      {'name': 'Sarah Wilson', 'role': 'UX Designer', 'in': '09:00 AM', 'out': '--', 'hrs': '4h 30m', 'status': 'Active', 'color': Colors.green},
      {'name': 'Mike Johnson', 'role': 'Developer', 'in': '09:15 AM', 'out': '--', 'hrs': '4h 15m', 'status': 'Late', 'color': Colors.orange},
      {'name': 'Anna Davis', 'role': 'Product Owner', 'in': '--', 'out': '--', 'hrs': '--', 'status': 'Absent', 'color': Colors.red},
      {'name': 'James Wilson', 'role': 'QA Engineer', 'in': '08:30 AM', 'out': '12:30 PM', 'hrs': '4h 00m', 'status': 'On Break', 'color': Colors.blue},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final emp = employees[index];
        return _buildMonitoringCard(context, emp);
      },
    );
  }

  Widget _buildMonitoringCard(BuildContext context, Map<String, dynamic> emp) {
    final color = emp['color'] as Color;
    
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          // Row 1: Profile + Status + Action
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Text(
                  (emp['name'] as String)[0], 
                  style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      emp['role'],
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
                  emp['status'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Actions Stacked/Icon
               GestureDetector(
                onTap: () {},
                child: Icon(Icons.more_vert, color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.5)),
          const SizedBox(height: 12),

          // Row 2: Metrics (In / Out / Hrs)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem(context, 'Time In', emp['in']),
              _buildMetricItem(context, 'Time Out', emp['out']),
              _buildMetricItem(context, 'Work Hrs', emp['hrs']),
            ],
          ),
        ],
      ),
    );
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
}
