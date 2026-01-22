import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/leave_service.dart';
import '../../../holidays/services/holiday_service.dart';

class LeaveTabletPortrait extends StatefulWidget {
  const LeaveTabletPortrait({super.key});

  @override
  State<LeaveTabletPortrait> createState() => _LeaveTabletPortraitState();
}

class _LeaveTabletPortraitState extends State<LeaveTabletPortrait> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LeaveService _leaveService;
  late HolidayService _holidayService;

  bool _isLoadingLeaves = false;
  List<dynamic> _leaves = [];
  
  bool _isLoadingHolidays = false;
  List<dynamic> _holidays = [];

  // Form State
  final _reasonController = TextEditingController();
  String _selectedType = 'Casual Leave';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = Provider.of<AuthService>(context, listen: false).dio;
      _leaveService = LeaveService(dio);
      _holidayService = HolidayService(dio);
      
      _fetchLeaves();
      _fetchHolidays();
    });
  }

  Future<void> _fetchLeaves() async {
    setState(() => _isLoadingLeaves = true);
    try {
      final data = await _leaveService.getMyHistory();
      if (mounted) setState(() => _leaves = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching leaves: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingLeaves = false);
    }
  }

  Future<void> _fetchHolidays() async {
    setState(() => _isLoadingHolidays = true);
    try {
      final data = await _holidayService.getHolidays();
      if (mounted) setState(() => _holidays = data);
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoadingHolidays = false);
    }
  }

  Future<void> _submitapplication() async {
      try {
        await _leaveService.submitLeaveRequest({
          'leave_type': _selectedType,
          'start_date': _startDate.toIso8601String().split('T')[0],
          'end_date': _endDate.toIso8601String().split('T')[0],
          'reason': _reasonController.text,
        });
        
        if (mounted) {
          Navigator.pop(context); // Close sheet
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Leave Requested Successfully")));
          _reasonController.clear();
          _fetchLeaves();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Submit Failed: $e")));
      }
  }

  void _showApplyLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("New Leave Request", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: ['Casual Leave', 'Sick Leave', 'Annual Leave', 'Unpaid Leave'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                  decoration: InputDecoration(
                    labelText: 'Leave Type', 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context, 
                            initialDate: _startDate, 
                            firstDate: DateTime(2020), 
                            lastDate: DateTime(2030)
                          );
                          if(d != null) setState(() => _startDate = d);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.date_range),
                          ),
                          child: Text("${_startDate.toLocal()}".split(' ')[0], style: GoogleFonts.poppins()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context, 
                            initialDate: _endDate, 
                            firstDate: DateTime(2020), 
                            lastDate: DateTime(2030)
                          );
                          if(d != null) setState(() => _endDate = d);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.event_busy),
                          ),
                          child: Text("${_endDate.toLocal()}".split(' ')[0], style: GoogleFonts.poppins()),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason', 
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitapplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, 
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Submit Request", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             _buildTabs(context),
             Padding(
               padding: const EdgeInsets.only(right: 24.0),
               child: _tabController.index == 1 ? ElevatedButton.icon(
                 onPressed: _showApplyLeaveDialog,
                 icon: const Icon(Icons.add, size: 18),
                 label: const Text("Apply"),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Theme.of(context).primaryColor,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                 ),
               ) : null,
             )
           ],
        ),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHolidaysList(context),
              _buildLeaveList(context),
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
      width: 350,
      margin: const EdgeInsets.all(24),
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Holidays List'),
          Tab(text: 'Leave Applications'),
        ],
      ),
    );
  }

  Widget _buildHolidaysList(BuildContext context) {
    if (_isLoadingHolidays) return const Center(child: CircularProgressIndicator());
    if (_holidays.isEmpty) return Center(child: Text("No holidays found", style: GoogleFonts.poppins(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _holidays.length,
      itemBuilder: (context, index) {
        final holiday = _holidays[index];
        final dt = DateTime.parse(holiday.date);
        
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('d').format(dt), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    Text(DateFormat('MMM').format(dt).toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(holiday.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(DateFormat('EEEE').format(dt), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaveList(BuildContext context) {
    if (_isLoadingLeaves) return const Center(child: CircularProgressIndicator());
    if (_leaves.isEmpty) return Center(child: Text("No leave requests found", style: GoogleFonts.poppins(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _leaves.length,
      itemBuilder: (context, index) {
        final leave = _leaves[index];
        
        Color statusColor = Colors.grey;
        if (leave['status'] == 'Approved') statusColor = Colors.green;
        if (leave['status'] == 'Rejected') statusColor = Colors.red;
        if (leave['status'] == 'Pending') statusColor = Colors.orange;

        return GlassContainer(
           margin: const EdgeInsets.only(bottom: 12),
           padding: const EdgeInsets.all(16),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text(leave['leave_type'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor.withOpacity(0.2))
                      ),
                      child: Text(leave['status'], style: GoogleFonts.poppins(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                    ),
                 ],
               ),
               const SizedBox(height: 8),
               Row(
                 children: [
                   Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                   const SizedBox(width: 6),
                   Text("${leave['start_date']} - ${leave['end_date']}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                 ],
               ),
               const SizedBox(height: 8),
               Text(leave['reason'] ?? '', style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[500])),
             ],
           ),
        );
      },
    );
  }
}
