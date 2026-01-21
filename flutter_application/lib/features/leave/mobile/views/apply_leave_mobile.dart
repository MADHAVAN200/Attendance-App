import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../views/apply_leave_view.dart';
import '../../../../shared/widgets/glass_container.dart';

class ApplyLeaveMobile extends StatelessWidget {
  final ApplyLeaveViewState controller;

  const ApplyLeaveMobile({super.key, required this.controller});

  // Since Mobile view might need vertical stacking, we'll try to fit the core components.
  // We'll reuse logic but adapt layout.
  
  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.transparent : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Stats (optional placement, fitting above tabs)
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildStatsGrid(context),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
                ),
                labelColor: const Color(0xFF6366F1),
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(child: Text("Apply Leave", style: TextStyle(height: 1.0))),
                  Tab(child: Text("View Leaves", style: TextStyle(height: 1.0))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Form
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        _buildForm(context),
                        const SizedBox(height: 24),
                        _buildCalendarSection(context),
                      ],
                    ),
                  ),
                  
                  // Tab 2: History
                  SingleChildScrollView(
                     padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                     child: _buildFullHistoryList(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = controller.stats;
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(context, 'TOTAL', stats['totalApplied']!.toString(), Icons.description, Colors.indigo),
        _buildStatCard(context, 'APPROVED', stats['approved']!.toString(), Icons.check_circle, Colors.green),
        _buildStatCard(context, 'PENDING', stats['pending']!.toString(), Icons.access_time, Colors.amber),
        _buildStatCard(context, 'REJECTED', stats['rejected']!.toString(), Icons.cancel, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[400])),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
          Text(count, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("Apply for Leave", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
             const SizedBox(height: 24),
             
             // Subject
             _label("Subject"),
             const SizedBox(height: 8),
             TextFormField(
               controller: controller.subjectController,
               decoration: _inputDec("e.g. Sick Leave"),
               style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
               validator: (val) => val!.isEmpty ? 'Required' : null,
             ),
             const SizedBox(height: 16),
             
             // Dates
             Row(
               children: [
                 Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Start Date"), const SizedBox(height: 8), _dateField(controller.startDate)])),
                 
                 const SizedBox(width: 12),
                 
                 Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("End Date"), const SizedBox(height: 8), _dateField(controller.endDate)])),
               ],
             ),
             const SizedBox(height: 16),
             
             // Reason
             _label("Reason"),
             const SizedBox(height: 8),
             TextFormField(
               controller: controller.reasonController,
               maxLines: 3,
               decoration: _inputDec("Reason..."),
               style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
               validator: (val) => val!.isEmpty ? 'Required' : null,
             ),
             const SizedBox(height: 16),

             // File Upload
             _label("Attach Document (Optional)"),
             const SizedBox(height: 8),
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: const Color(0xFF0F172A),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey[700]!, width: 1), 
               ),
               child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text("Attach file", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis)),
                  ],
               ),
             ),
             const SizedBox(height: 24),
             
             // Submit Button
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: controller.isSubmitting ? null : controller.submitForm,
                 style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   backgroundColor: const Color(0xFF6366F1),
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
                 child: controller.isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("SUBMIT REQUEST", style: TextStyle(fontWeight: FontWeight.bold)),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[400]));

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF0F172A), 
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
    );
  }

  Widget _dateField(DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date != null ? DateFormat('dd-MM-yyyy').format(date) : "dd-mm-yyyy",
            style: GoogleFonts.poppins(color: date != null ? Colors.white : Colors.grey[700], fontSize: 12),
          ),
          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(
         color: const Color(0xFF1E293B),
         borderRadius: BorderRadius.circular(16), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _calendarHeader(context),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['SUN','MON','TUE','WED','THU','FRI','SAT'].map((d) => 
               SizedBox(width: 30, child: Center(child: Text(d, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500]))))
            ).toList(),
          ),
          const SizedBox(height: 8),

          _calendarGrid(context),
          const SizedBox(height: 12), 
          _calendarLegend(context),
          const SizedBox(height: 24),

          Text(
            "HOLIDAYS IN ${DateFormat('MMMM').format(controller.currentDate).toUpperCase()}",
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          if (controller.holidays.any((h) => DateTime.parse(h.date).month == controller.currentDate.month))
             ...controller.holidays.where((h) => DateTime.parse(h.date).month == controller.currentDate.month).map((h) => 
               Padding(
                 padding: const EdgeInsets.only(top: 6),
                 child: Text("• ${h.name} (${h.date})", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400])),
               )
             )
          else
            Text("No holidays this month", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _calendarHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => controller.changeMonth(-1), 
          icon: const Icon(Icons.chevron_left, size: 20, color: Colors.grey),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          DateFormat('MMMM yyyy').format(controller.currentDate),
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), 
        ),
        IconButton(
          onPressed: () => controller.changeMonth(1), 
          icon: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _calendarGrid(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(controller.currentDate.year, controller.currentDate.month);
    final firstDayOffset = DateTime(controller.currentDate.year, controller.currentDate.month, 1).weekday % 7;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, 
        childAspectRatio: 1.3, 
      ),
      itemCount: daysInMonth + firstDayOffset,
      itemBuilder: (context, index) {
        if (index < firstDayOffset) return const SizedBox();
        
        final day = index - firstDayOffset + 1;
        final date = DateTime(controller.currentDate.year, controller.currentDate.month, day);
        bool isSelected = false;
        bool inRange = false;
        bool isHoliday = controller.holidays.any((h) => isSameDay(DateTime.parse(h.date), date));
        
        if (controller.startDate != null) {
          if (isSameDay(controller.startDate!, date)) isSelected = true;
          if (controller.endDate != null) {
             if (isSameDay(controller.endDate!, date)) isSelected = true;
             if (date.isAfter(controller.startDate!) && date.isBefore(controller.endDate!)) inRange = true;
          }
        }

        return GestureDetector(
          onTap: () => controller.onDateTap(date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6366F1) : (inRange ? const Color(0xFF6366F1).withOpacity(0.2) : (isHoliday ? Colors.amber.withOpacity(0.2) : Colors.transparent)),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              "$day",
              style: TextStyle(
                color: isSelected ? Colors.white : (inRange ? const Color(0xFF6366F1) : (isHoliday ? Colors.amber : Colors.white)),
                fontSize: 12,
                fontWeight: (isSelected || isHoliday) ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _calendarLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.amber.withOpacity(0.2), "Holiday"),
        const SizedBox(width: 16),
        _legendItem(const Color(0xFF6366F1), "Selected"),
      ],
    );
  }
  
  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFullHistoryList(BuildContext context) {
    if (controller.leaves.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text("No leave history found", style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.leaves.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final leave = controller.leaves[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(leave.type, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  _statusBadge(leave.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text("${_fmt(leave.startDate)} - ${_fmt(leave.endDate)}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400])),
                ],
              ),
              if (leave.reason != null && leave.reason!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  leave.reason!,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  String _fmt(String iso) {
    try {
      return DateFormat('MMM d').format(DateTime.parse(iso));
    } catch (e) { return iso; }
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.amber;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
