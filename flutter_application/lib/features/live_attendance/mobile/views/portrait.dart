import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../live_attendance_controller.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_tab_switcher.dart';

class MobilePortrait extends StatelessWidget {
  const MobilePortrait({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LiveAttendanceController>();

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const Drawer(
        width: 280,
        child: AppSidebar(), // Sidebar in Drawer
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: CustomTabSwitcher(
                activeTab: controller.activeTab,
                onTabChanged: controller.setActiveTab,
                tabs: [
                  TabData(id: 'live', label: 'Live Dashboard'),
                  TabData(id: 'requests', label: 'Correction Requests', count: controller.requests.length),
                ],
              ),
            ),
            
            Expanded(
              child: controller.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : controller.activeTab == 'live' 
                      ? _buildLiveDashboard(context, controller)
                      : _buildRequestsTab(context, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDashboard(BuildContext context, LiveAttendanceController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Stats Grid (2 Cols for Mobile Portrait)
           GridView.count(
             crossAxisCount: 2,
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             childAspectRatio: 1.6,
             mainAxisSpacing: 12,
             crossAxisSpacing: 12,
             children: [
               _buildStatCard(context, 'Total Present', controller.stats.present.toString(), Icons.check_circle_outline, Colors.green),
               _buildStatCard(context, 'Late Arrivals', controller.stats.late.toString(), Icons.access_time, Colors.amber),
               _buildStatCard(context, 'Absent', controller.stats.absent.toString(), Icons.cancel_outlined, Colors.red),
               _buildStatCard(context, 'Active', controller.stats.active.toString(), Icons.timer, Colors.blue),
             ],
           ),
           
           const SizedBox(height: 16),
           
           // Toolbar
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: Theme.of(context).cardColor,
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
             ),
             child: Column(
               children: [
                  TextField(
                    onChanged: controller.setSearchTerm,
                    decoration: InputDecoration(
                        hintText: 'Search employee...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildDeptDropdown(controller)),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.calendar_today), onPressed: () async {
                         final picked = await showDatePicker(
                            context: context, 
                            initialDate: controller.selectedDate, 
                            firstDate: DateTime(2020), 
                            lastDate: DateTime.now()
                          );
                          if(picked != null) controller.updateDate(picked);
                      }),
                    ],
                  )
               ],
             ),
           ),

           const SizedBox(height: 16),

           if (controller.activeView == 'cards')
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.filteredData.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildEmployeeCard(context, controller.filteredData[index]),
              )
           else
              const Center(child: Text("Graph View Not Implemented")) // Placeholder
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(label, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12, fontWeight: FontWeight.w500)),
               Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, CombinedAttendance item) {
    final isAbsent = item.status == 'Absent';
    final isActive = item.status == 'Active' || item.status == 'Late Active';
    final isLate = item.status.contains('Late');
    Color statusColor = isAbsent ? Colors.grey : (isLate ? Colors.amber[700]! : (isActive ? Colors.blue : Colors.green));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(item.avatarChar)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(item.role, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(item.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text('In: ${item.timeIn}'),
                  Text('Out: ${item.timeOut}'),
              ]
          )
        ],
      ),
    );
  }
  
  Widget _buildDeptDropdown(LiveAttendanceController controller) {
    return DropdownButtonFormField<String>(
          value: controller.deptFilter,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: ['All', 'Sales', 'Engineering', 'HR'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value == 'All' ? 'All Depts' : value));
          }).toList(),
          onChanged: (v) => controller.setDeptFilter(v!),
    );
  }

  Widget _buildRequestsTab(BuildContext context, LiveAttendanceController controller) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.requests.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (c, i) => Card(
            child: ListTile(
                leading: CircleAvatar(child: Text(controller.requests[i].avatarChar)),
                title: Text(controller.requests[i].name),
                subtitle: Text(controller.requests[i].type),
                trailing: Text(controller.requests[i].status),
            ),
        ),
      );
  }
}
