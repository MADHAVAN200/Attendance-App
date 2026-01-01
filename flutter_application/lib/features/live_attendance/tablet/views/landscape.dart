import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../live_attendance_controller.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_tab_switcher.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class TabletLandscape extends StatelessWidget {
  const TabletLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LiveAttendanceController>();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const CustomAppBar(showDrawerButton: false),
                body: Column(
                  children: [
                   Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                      color: Theme.of(context).cardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end, // Tabs on right or just remove title?
                        // CustomAppBar handles Title. Tabs should be separate or below?
                        // Original code had Title + Tabs in one row.
                        // Now Title is in AppBar. Tabs need to be somewhere.
                        // Let's keep tabs in a container below AppBar.
                        children: [
                          Expanded(
                             child: CustomTabSwitcher(
                               activeTab: controller.activeTab,
                               onTabChanged: controller.setActiveTab,
                               tabs: [
                                 TabData(id: 'live', label: 'Live Dashboard'),
                                 TabData(id: 'requests', label: 'Correction Requests', count: controller.requests.length),
                               ],
                             ),
                          ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDashboard(BuildContext context, LiveAttendanceController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Stats Grid (4 Cols)
           GridView.count(
             crossAxisCount: 4,
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             childAspectRatio: 2.2,
             mainAxisSpacing: 16,
             crossAxisSpacing: 16,
             children: [
               _buildStatCard(context, 'Total Present', controller.stats.present.toString(), Icons.check_circle_outlined, const Color(0xFF10B981)),
               _buildStatCard(context, 'Late Arrivals', controller.stats.late.toString(), Icons.access_time, const Color(0xFFF59E0B)),
               _buildStatCard(context, 'Absent', controller.stats.absent.toString(), Icons.person_off_outlined, const Color(0xFFEF4444)),
               _buildStatCard(context, 'On Break', controller.stats.active.toString(), Icons.coffee_outlined, const Color(0xFF3B82F6)),
             ],
           ),
           
           const SizedBox(height: 32),
           
           // Real-time Monitoring Section
           Container(
             decoration: BoxDecoration(
               color: Theme.of(context).cardColor,
               borderRadius: BorderRadius.circular(16),
               border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
               boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
               ],
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // Header
                 Padding(
                   padding: const EdgeInsets.all(24),
                   child: Row(
                     children: [
                       Text('Real-time Monitoring', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                       const Spacer(),
                       SizedBox(
                         width: 280,
                         child: TextField(
                           onChanged: controller.setSearchTerm,
                           style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13),
                           decoration: InputDecoration(
                               hintText: 'Search employee...',
                               hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                               prefixIcon: Icon(Icons.search, size: 18, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                               filled: true,
                               fillColor: Theme.of(context).scaffoldBackgroundColor,
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                           ),
                         ),
                       ),
                       const SizedBox(width: 16),
                       _buildFilterButton(context, 'All Depts'),
                       const SizedBox(width: 12),
                       _buildIconButton(context, Icons.download_outlined),
                     ],
                   ),
                 ),
                 Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                 
                 // Table
                 SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: ConstrainedBox(
                     constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 300), // Ensure full width
                     child: DataTable(
                       headingRowColor: WidgetStateProperty.all(Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5)),
                       horizontalMargin: 24,
                       columnSpacing: 24,
                       columns: const [
                         DataColumn(label: Text('EMPLOYEE')),
                         DataColumn(label: Text('TIME IN')),
                         DataColumn(label: Text('TIME OUT')),
                         DataColumn(label: Text('WORKING HOURS')),
                         DataColumn(label: Text('STATUS')),
                         DataColumn(label: Text('')), // Actions
                       ],
                       rows: controller.filteredData.map((item) {
                         return DataRow(
                           cells: [
                             DataCell(Row(
                               children: [
                                 CircleAvatar(
                                   radius: 16,
                                   backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                                   child: Text(item.avatarChar, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                 ),
                                 const SizedBox(width: 12),
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   children: [
                                     Text(item.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                     Text(item.role, style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                                   ],
                                 ),
                               ],
                             )),
                             DataCell(Row(
                               children: [
                                 Icon(Icons.access_time, size: 14, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                                 const SizedBox(width: 8),
                                 Text(item.timeIn, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyMedium?.color)),
                               ],
                             )),
                             DataCell(Text(item.timeOut, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyMedium?.color))),
                             DataCell(Text(item.hours, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyMedium?.color))),
                             DataCell(_buildStatusBadge(context, item.status)),
                             DataCell(Icon(Icons.more_vert, size: 18, color: Theme.of(context).iconTheme.color?.withOpacity(0.5))),
                           ],
                         );
                       }).toList(),
                     ),
                   ),
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(BuildContext context, LiveAttendanceController controller) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Requests', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${controller.requests.length} Total', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.requests.length,
                      separatorBuilder: (c, i) => Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      itemBuilder: (context, index) {
                        final req = controller.requests[index];
                        final isSelected = req.id == controller.selectedRequestId;
                        return InkWell(
                          onTap: () => controller.setSelectedRequestId(req.id),
                          child: Container(
                            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(child: Text(req.avatarChar)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(req.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                          _buildRequestStatus(req.type, isType: true),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(req.role, style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                                              const SizedBox(width: 4),
                                              Text(req.date, style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                                            ],
                                          ),
                                          Text(req.status, style: TextStyle(
                                            color: req.status == 'Pending' ? Colors.orange : (req.status == 'Approved' ? Colors.green : Colors.red),
                                            fontSize: 12, fontWeight: FontWeight.bold
                                          )),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Detail
            Expanded(
              flex: 6,
              child: _buildRequestDetail(context, controller),
            ),
          ],
        ),
      );
  }

  Widget _buildRequestDetail(BuildContext context, LiveAttendanceController controller) {
    // Find selected
    final req = controller.requests.firstWhere((r) => r.id == controller.selectedRequestId, orElse: () => controller.requests.first);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Request #${req.id}', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.headlineSmall?.color)),
                   const SizedBox(height: 4),
                   Text('Submitted on ${req.timeline.first.time}', style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color)),
                 ],
               ),
               Row(
                 children: [
                   OutlinedButton.icon(
                     onPressed: () {},
                     icon: const Icon(Icons.close, size: 16),
                     label: const Text('Reject'),
                     style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                   ),
                   const SizedBox(width: 12),
                   ElevatedButton.icon(
                     onPressed: () {},
                     icon: const Icon(Icons.check, size: 16),
                     label: const Text('Approve'),
                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                   ),
                 ],
               )
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CORRECTION DETAILS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color)),
                    const SizedBox(height: 16),
                    _buildDetailBox(context, 'Request Type', req.type, isHighlight: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDetailBox(context, 'System Time', req.systemTime)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDetailBox(context, 'Requested Time', req.requestedTime, isHighlight: true)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('JUSTIFICATION', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                      ),
                      child: Text('"${req.reason}"', style: GoogleFonts.inter(fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('AUDIT TRAIL', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 16),
          ...req.timeline.map((event) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    Text('${event.time} • by ${event.actor}', style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
  
  // Helper Widgets
  Widget _buildFilterButton(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(width: 8),
          Icon(Icons.filter_list, size: 16, color: Theme.of(context).iconTheme.color),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
    );
  }

  Widget _buildDetailBox(BuildContext context, String label, String value, {bool isHighlight = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isHighlight ? Theme.of(context).primaryColor.withOpacity(0.3) : Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isHighlight ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildRequestStatus(String text, {bool isType = false}) {
    Color color = isType ? Colors.orange : Colors.green;
    return Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold));
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    if (status.toLowerCase().contains('present')) {
      color = const Color(0xFF10B981); // Green
    } else if (status.toLowerCase().contains('absent')) {
      color = const Color(0xFFEF4444); // Red
    } else if (status.toLowerCase().contains('half day') || status.toLowerCase().contains('break')) {
      color = const Color(0xFF3B82F6); // Blue
    } else if (status.toLowerCase().contains('late')) {
      color = const Color(0xFFF59E0B); // Orange
    } else {
      color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(label, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14, fontWeight: FontWeight.w500)),
               const SizedBox(height: 8),
               Text(value, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

}
