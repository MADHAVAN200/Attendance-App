import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/leave_service.dart';
import '../../../holidays/services/holiday_service.dart';

class LeaveMobileView extends StatefulWidget {
  const LeaveMobileView({super.key});

  @override
  State<LeaveMobileView> createState() => _LeaveMobileViewState();
}

class _LeaveMobileViewState extends State<LeaveMobileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LeaveService _leaveService;
  late HolidayService _holidayService;

  bool _isLoadingLeaves = false;
  List<dynamic> _leaves = [];
  
  bool _isLoadingHolidays = false;
  List<dynamic> _holidays = [];

  // Form State
  final _reasonController = TextEditingController();
  final _otherTypeController = TextEditingController(); // ADDED
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
        if (_selectedType == 'Other' && _otherTypeController.text.trim().isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please specify the leave type")));
           return;
        }

        await _leaveService.submitLeaveRequest({
          'leave_type': _selectedType == 'Other' ? _otherTypeController.text : _selectedType,
          'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
          'end_date': DateFormat('yyyy-MM-dd').format(_endDate),
          'reason': _reasonController.text,
        });
        
        if (mounted) {
          Navigator.pop(context); // Close sheet
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Leave Requested Successfully")));
          _reasonController.clear();
          _otherTypeController.clear(); // Clear other
          setState(() { // Reset
             _selectedType = 'Casual Leave'; 
          });
          _fetchLeaves();
        }
      } catch (e) {
        String msg = "Submit Failed: $e";
        if (e is DioException && e.response?.data != null && e.response!.data is Map) {
           msg = e.response!.data['message'] ?? msg;
        }
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
  }

  Future<void> _withdrawRequest(int id) async {
    try {
      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Withdraw Request", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to withdraw this leave request?", style: GoogleFonts.poppins(fontSize: 14)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true), 
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Withdraw")
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _leaveService.withdrawRequest(id);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Withdrawn Successfully")));
           _fetchLeaves();
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Withdraw Failed: $e")));
    }
  }

  void _showApplyLeaveSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark; 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2939) : Theme.of(context).scaffoldBackgroundColor,
          // Removed top radius to make it look more like a bottom sheet
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(Icons.add, size: 20, color: Color(0xFF5B60F6)),
                        const SizedBox(width: 8),
                        Text("Apply for Leave", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: isDark ? Colors.white10 : Colors.grey.shade200, height: 1),
                    const SizedBox(height: 24),

                    // Leave Type
                    Text("LEAVE TYPE", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      dropdownColor: isDark ? const Color(0xFF1E2939) : Colors.white,
                      style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                      items: ['Casual Leave', 'Sick Leave', 'Other'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: const Color(0xFF5B60F6)),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 20),

                    // Conditional: Specify Other
                    if (_selectedType == 'Other') ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _otherTypeController,
                        style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                          hintText: "Enter custom leave type",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: const Color(0xFF5B60F6)),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("START DATE", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
                              const SizedBox(height: 8),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () async {
                                    final d = await showDatePicker(
                                      context: context, 
                                      initialDate: _startDate, 
                                      firstDate: DateTime(2020), 
                                      lastDate: DateTime(2030),
                                      builder: (ctx, child) => Theme(
                                        data: isDark ? ThemeData.dark().copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Color(0xFF5B60F6),
                                            onPrimary: Colors.white,
                                            surface: Color(0xFF1E2939),
                                            onSurface: Colors.white,
                                          )
                                        ) : ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF5B60F6))),
                                        child: child!,
                                      ),
                                    );
                                    if(d != null && mounted) setState(() => _startDate = d);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[500]),
                                        const SizedBox(width: 10),
                                        Text(DateFormat('yyyy-MM-dd').format(_startDate), style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("END DATE", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
                              const SizedBox(height: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context, 
                                    initialDate: _endDate, 
                                    firstDate: DateTime(2020), 
                                    lastDate: DateTime(2030),
                                    builder: (ctx, child) => Theme(
                                      data: isDark ? ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: Color(0xFF5B60F6),
                                          onPrimary: Colors.white,
                                          surface: Color(0xFF1E2939),
                                          onSurface: Colors.white,
                                        )
                                      ) : ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF5B60F6))),
                                      child: child!,
                                    ),
                                  );
                                  if(d != null && mounted) setState(() => _endDate = d);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[500]),
                                      const SizedBox(width: 10),
                                      Text(DateFormat('yyyy-MM-dd').format(_endDate), style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Reason
                    Text("REASON", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
                        hintText: "Why do you need leave?",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: const Color(0xFF5B60F6)),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Attachment
                    Text("ATTACHMENT (OPTIONAL)", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A).withOpacity(0.5) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B60F6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.attach_file, size: 14, color: Color(0xFF5B60F6)),
                          ),
                          const SizedBox(width: 12),
                          Text("Click to attach document...", style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitapplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B60F6), 
                          foregroundColor: Colors.white, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text("Submit Request", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showApplyLeaveSheet,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTabs(context),
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
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicator: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        labelColor: isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Holidays List'),
          Tab(text: 'Leaves'),
        ],
      ),
    );
  }

  Widget _buildHolidaysList(BuildContext context) {
    if (_isLoadingHolidays) return const Center(child: CircularProgressIndicator());
    if (_holidays.isEmpty) return Center(child: Text("No holidays found", style: GoogleFonts.poppins(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _holidays.length,
      itemBuilder: (context, index) {
        final holiday = _holidays[index];
        final dt = DateTime.parse(holiday.date);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('d').format(dt), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF818CF8) : Theme.of(context).primaryColor)),
                    Text(DateFormat('MMM').format(dt).toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF818CF8) : Theme.of(context).primaryColor)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _leaves.length,
      itemBuilder: (context, index) {
        final leave = _leaves[index];
        
        Color statusColor = Colors.grey;
        final status = leave['status']?.toString().toLowerCase().trim() ?? '';
        if (status == 'approved') statusColor = const Color(0xFF22C55E);
        if (status == 'rejected') statusColor = const Color(0xFFEF4444);
        if (status == 'pending') statusColor = const Color(0xFFF59E0B);

        return GlassContainer(
           margin: const EdgeInsets.only(bottom: 12),
           padding: const EdgeInsets.all(16),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Expanded(
                       child: Text(leave['leave_type'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "${leave['start_date']} - ${leave['end_date']}", 
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (leave['status'] == 'Pending')
                      InkWell(
                        onTap: () => _withdrawRequest(leave['id']),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.1),
                          ),
                          child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        ),
                      ),
                  ],
                ),
             ],
           ),
        );
      },
    );
  }
}
