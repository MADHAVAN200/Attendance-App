import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

import '../../../dashboard/tablet/widgets/stat_card.dart';
import 'correction_requests_view.dart';

class LiveAttendanceView extends StatefulWidget {
  const LiveAttendanceView({super.key});

  @override
  State<LiveAttendanceView> createState() => _LiveAttendanceViewState();
}

class _LiveAttendanceViewState extends State<LiveAttendanceView> with SingleTickerProviderStateMixin {
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
              const CorrectionRequestsView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(32, 32, 32, 24),
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primaryColor, // Solid color for better visibility
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor), // Solid border
        ),
        labelColor: Colors.white, // White text for selected tab
        unselectedLabelColor: isDark ? Colors.white60 : Colors.grey, // Visible unselected text
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        tabs: [
          const Tab(text: 'Live Dashboard'),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Correction Requests'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red, // Visible on both Blue (selected) and White/Dark (unselected) backgrounds
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '5',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Present',
                  value: '142',
                  total: '/ 150',
                  percentage: '+5%',
                  contextText: 'vs yesterday',
                  isPositive: true,
                  icon: Icons.people_alt,
                  baseColor: Color(0xFF5B60F6),
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: 'Late Arrivals',
                  value: '12',
                  total: '',
                  percentage: '-2%',
                  contextText: 'vs yesterday',
                  isPositive: true,
                  icon: Icons.access_time_filled,
                  baseColor: Color(0xFFF59E0B),
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: 'Absent',
                  value: '8',
                  total: '',
                  percentage: '+1%',
                  contextText: 'vs yesterday',
                  isPositive: false,
                  icon: Icons.person_off,
                  baseColor: Color(0xFFEF4444),
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: StatCard(
                  title: 'On Break',
                  value: '45',
                  total: '',
                  percentage: '',
                  contextText: 'Currently',
                  isPositive: true,
                  icon: Icons.coffee,
                  baseColor: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Monitoring Table Section
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Table Header (Search, Filters)
                Row(
                  children: [
                    Text(
                      'Real-time Monitoring',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    // Search
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search employee...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Filter
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'All Departments',
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: ['All Departments', 'Engineering', 'Design', 'Sales']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 13))))
                              .toList(),
                          onChanged: (_) {},
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Data Table
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: 24,
                    headingTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14, // Standard Table Header
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    dataRowColor: MaterialStateProperty.all(Colors.transparent),
                    columns: const [
                      DataColumn(label: Text('EMPLOYEE')),
                      DataColumn(label: Text('TIME IN')),
                      DataColumn(label: Text('TIME OUT')),
                      DataColumn(label: Text('WORKING HRS')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: [
                      _buildMonitoringRow(context, 'Sarah Wilson', '09:00 AM', '--', '4h 30m', 'Active', Colors.green),
                      _buildMonitoringRow(context, 'Mike Johnson', '09:15 AM', '--', '4h 15m', 'Late', Colors.orange),
                      _buildMonitoringRow(context, 'Anna Davis', '--', '--', '--', 'Absent', Colors.red),
                      _buildMonitoringRow(context, 'James Wilson', '08:30 AM', '12:30 PM', '4h 00m', 'On Break', Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildMonitoringRow(BuildContext context, String name, String inTime, String outTime, String hours, String status, Color color) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.1),
                child: Text(name[0], style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: textColor)),
            ],
          ),
        ),
        DataCell(Text(inTime, style: GoogleFonts.poppins(color: textColor))),
        DataCell(Text(outTime, style: GoogleFonts.poppins(color: textColor))),
        DataCell(Text(hours, style: GoogleFonts.poppins(color: textColor))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
