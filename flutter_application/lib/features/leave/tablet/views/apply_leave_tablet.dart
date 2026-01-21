import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../views/apply_leave_view.dart';

class ApplyLeaveTablet extends StatelessWidget {
  final ApplyLeaveViewState controller;

  const ApplyLeaveTablet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.transparent : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: DefaultTabController(
        length: 2,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Stats Row (Always visible at top)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: _buildStatsRow(context),
              ),
              const SizedBox(height: 32),

              // 2. Pill Tabs (Full Width)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                margin: const EdgeInsets.only(bottom: 32),
                child: Container(
                  padding: const EdgeInsets.all(4),
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
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    dividerColor: Colors.transparent,
                    tabs: const [
                       Tab(child: Text("Apply Leave", style: TextStyle(height: 1.0))),
                       Tab(child: Text("View Leaves", style: TextStyle(height: 1.0))),
                    ],
                  ),
                ),
              ),
              
              // 3. Content
              SizedBox(
                height: 800, // Fixed height for TabBarView to work inside ScrollView or use Expanded if parent allows
                // A better approach for Tablet scrollable is separating the scrollview.
                // But to match previous structure, we'll wrap the inner views.
                // However, TabBarView needs bounded height. 
                // Let's use a Container with constraints or just let the children scroll independently 
                // and put the Stats/Tabs outside.
                // Since I wrapped everything in SingleChildScrollView, TabBarView will crash.
                // Correction: The original code intended the whole page to scroll or parts of it?
                // The broken code had SingleScrollViews INSIDE the TabBarView.
                // So the outer structure should NOT be a SingleChildScrollView if using TabBarView with Expanded.
                child: TabBarView(
                  children: [
                    // Tab 1: Apply Leave (Form + Calendar)
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildForm(context)),
                              const SizedBox(width: 32),
                              Expanded(flex: 1, child: _buildCalendarSection(context)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Tab 2: View Leaves (Full History)
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: _buildFullHistoryList(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final stats = controller.stats;
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Total', stats['totalApplied']!, Icons.description, Colors.indigo)),
        const SizedBox(width: 24),
        Expanded(child: _buildStatCard(context, 'Approved', stats['approved']!, Icons.check_circle, Colors.green)),
        const SizedBox(width: 24),
        Expanded(child: _buildStatCard(context, 'Pending', stats['pending']!, Icons.access_time, Colors.amber)),
        const SizedBox(width: 24),
        Expanded(child: _buildStatCard(context, 'Rejected', stats['rejected']!, Icons.cancel, Colors.red)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark card background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(), 
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[400])
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            count.toString(), 
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark card
        borderRadius: BorderRadius.circular(24),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(10), 
                   decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), 
                   child: const Icon(Icons.description, color: Color(0xFF6366F1), size: 20)
                 ),
                 const SizedBox(width: 12),
                 Text("Apply for Leave", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
               ],
             ),
             const SizedBox(height: 32),
             
             // Subject
             _label("Subject"),
             const SizedBox(height: 8),
             TextFormField(
               controller: controller.subjectController,
               decoration: _inputDec("e.g. Sick Leave, Vacation, Family Emergency"),
               style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
               validator: (val) => val!.isEmpty ? 'Required' : null,
             ),
             const SizedBox(height: 24),
             
             // Dates
             Row(
               children: [
                 Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("Start Date"), const SizedBox(height: 8), _dateField(controller.startDate)])),
                 const SizedBox(width: 24),
                 Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("End Date"), const SizedBox(height: 8), _dateField(controller.endDate)])),
               ],
             ),
             const SizedBox(height: 24),
             
             // Reason
             _label("Reason"),
             const SizedBox(height: 8),
             TextFormField(
               controller: controller.reasonController,
               maxLines: 5,
               decoration: _inputDec("Detailed explanation..."),
               style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
               validator: (val) => val!.isEmpty ? 'Required' : null,
             ),
             const SizedBox(height: 24),

             // File Upload (Dashed Box)
             _label("Attach Document (Optional)"),
             const SizedBox(height: 8),
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: const Color(0xFF0F172A),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey[700]!, width: 1, style: BorderStyle.none), // Ideally dashed
               ),
               child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Text("Click to attach file or drag here", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                  ],
               ),
             ),
             const SizedBox(height: 32),
             
             // Submit
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: controller.isSubmitting ? null : controller.submitForm,
                 style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 20),
                   backgroundColor: const Color(0xFF6366F1),
                   foregroundColor: Colors.white,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   elevation: 0,
                 ),
                 child: controller.isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("SUBMIT REQUEST", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
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
      fillColor: const Color(0xFF0F172A), // Darker input bg
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
    );
  }

  Widget _dateField(DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
            style: GoogleFonts.poppins(color: date != null ? Colors.white : Colors.grey[700], fontSize: 13),
          ),
          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
         color: const Color(0xFF1E293B),
         borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _calendarHeader(context),
          const SizedBox(height: 24),
          
          // Weekday Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['SUN','MON','TUE','WED','THU','FRI','SAT'].map((d) => 
               SizedBox(width: 30, child: Center(child: Text(d, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500]))))
            ).toList(),
          ),
          const SizedBox(height: 12),

          _calendarGrid(context),
          const SizedBox(height: 24),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               _legendDot(Colors.amber, "Holiday"),
               const SizedBox(width: 16),
               _legendDot(const Color(0xFF6366F1), "Selected"),
            ],
          ),
          const SizedBox(height: 32),

          // Holidays Footer
          Text(
            "HOLIDAYS IN ${DateFormat('MMMM').format(controller.currentDate).toUpperCase()}",
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          if (controller.holidays.any((h) => DateTime.parse(h.date).month == controller.currentDate.month))
             ...controller.holidays.where((h) => DateTime.parse(h.date).month == controller.currentDate.month).map((h) => 
               Padding(
                 padding: const EdgeInsets.only(top: 6),
                 child: Text("• ${h.name} (${h.date})", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400])),
               )
             )
          else
            Text("No holidays this month", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _calendarHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => controller.changeMonth(-1), 
          icon: const Icon(Icons.chevron_left, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          DateFormat('MMMM yyyy').format(controller.currentDate),
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => controller.changeMonth(1), 
          icon: const Icon(Icons.chevron_right, size: 20),
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
        childAspectRatio: 1.3, // Compressed height
        mainAxisSpacing: 4, // Reduced spacing
        crossAxisSpacing: 4, // Reduced spacing
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

        Color bgColor = Colors.transparent;
        Color textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;

        if (isSelected) {
          bgColor = const Color(0xFF6366F1);
          textColor = Colors.white;
        } else if (inRange) {
          bgColor = const Color(0xFF6366F1).withOpacity(0.2);
          textColor = const Color(0xFF6366F1);
        } else if (isHoliday) {
          bgColor = Colors.amber.withOpacity(0.2);
          textColor = Colors.amber;
        }

        return GestureDetector(
          onTap: () => controller.onDateTap(date),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected || inRange ? null : Border.all(color: Colors.transparent),
            ),
            alignment: Alignment.center,
            child: Text(
              "$day",
              style: TextStyle(color: textColor, fontWeight: (isSelected || isHoliday) ? FontWeight.bold : FontWeight.normal),
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFullHistoryList(BuildContext context) {
    if (controller.leaves.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[700]),
            const SizedBox(height: 24),
            Text("No leave history found", style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 18)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.leaves.length,
        separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 32),
        itemBuilder: (context, index) {
          final leave = controller.leaves[index];
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.description, color: Colors.indigo),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.type, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 4),
                     Text(leave.reason ?? 'No reason provided', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("DURATION", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                     const SizedBox(height: 4),
                    Text("${_fmt(leave.startDate)} - ${_fmt(leave.endDate)}", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
              _statusBadge(leave.status),
              const SizedBox(width: 16),
              if (leave.status == 'Pending')
                IconButton(
                  onPressed: () => controller.withdrawLeave(leave.id), 
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Withdraw Request",
                )
            ],
          );
        },
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
