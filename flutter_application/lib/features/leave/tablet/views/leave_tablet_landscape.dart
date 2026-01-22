import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../services/leave_service.dart';
import '../../../holidays/services/holiday_service.dart';

class LeaveTabletLandscape extends StatefulWidget {
  const LeaveTabletLandscape({super.key});

  @override
  State<LeaveTabletLandscape> createState() => _LeaveTabletLandscapeState();
}

class _LeaveTabletLandscapeState extends State<LeaveTabletLandscape> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LeaveService _leaveService;
  late HolidayService _holidayService;

  bool _isLoadingLeaves = false;
  List<dynamic> _leaves = [];
  dynamic _selectedLeave; 

  bool _isLoadingHolidays = false;
  List<dynamic> _holidays = [];

  // Form State for Apply Dialog
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _formSelectedType = 'Casual Leave';
  DateTime _formStartDate = DateTime.now();
  DateTime _formEndDate = DateTime.now();

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
      if (mounted) {
        setState(() {
          _leaves = data;
          if (_leaves.isNotEmpty && _selectedLeave == null) {
            _selectedLeave = _leaves.first;
          }
        });
      }
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
      if (!_formKey.currentState!.validate()) return;
      try {
        await _leaveService.submitLeaveRequest({
          'leave_type': _formSelectedType,
          'start_date': _formStartDate.toIso8601String().split('T')[0],
          'end_date': _formEndDate.toIso8601String().split('T')[0],
          'reason': _reasonController.text,
        });
        
        if (mounted) {
          Navigator.pop(context); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Leave Requested Successfully")));
          _reasonController.clear();
          _fetchLeaves();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Submit Failed: $e")));
      }
  }

  void _showApplyLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("New Leave Request", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  DropdownButtonFormField<String>(
                    value: _formSelectedType,
                    items: ['Casual Leave', 'Sick Leave', 'Annual Leave', 'Unpaid Leave'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _formSelectedType = v!),
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
                              initialDate: _formStartDate, 
                              firstDate: DateTime(2020), 
                              lastDate: DateTime(2030)
                            );
                            if(d != null) setState(() => _formStartDate = d);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.date_range),
                            ),
                            child: Text("${_formStartDate.toLocal()}".split(' ')[0], style: GoogleFonts.poppins()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context, 
                              initialDate: _formEndDate, 
                              firstDate: DateTime(2020), 
                              lastDate: DateTime(2030)
                            );
                            if(d != null) setState(() => _formEndDate = d);
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.event_busy),
                            ),
                            child: Text("${_formEndDate.toLocal()}".split(' ')[0], style: GoogleFonts.poppins()),
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
                    validator: (v) => v!.isEmpty ? 'Please enter a reason' : null,
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
              padding: const EdgeInsets.only(right: 32.0),
              child: _tabController.index == 1 ? ElevatedButton.icon(
                onPressed: _showApplyLeaveDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Apply Leave"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              _buildMasterDetailLeave(context),
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
      width: 400,
      margin: const EdgeInsets.fromLTRB(32, 24, 32, 24),
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
          Tab(text: 'Leave Application'),
        ],
      ),
    );
  }

  Widget _buildHolidaysList(BuildContext context) {
     if (_isLoadingHolidays) return const Center(child: CircularProgressIndicator());
    if (_holidays.isEmpty) return Center(child: Text("No holidays found", style: GoogleFonts.poppins(color: Colors.grey)));

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        childAspectRatio: 2.5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _holidays.length,
      itemBuilder: (context, index) {
        final holiday = _holidays[index];
        final dt = DateTime.parse(holiday.date);
        
        return GlassContainer(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(holiday.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _buildMasterDetailLeave(BuildContext context) {
    if (_isLoadingLeaves) return const Center(child: CircularProgressIndicator());
    if (_leaves.isEmpty) return Center(child: Text("No leave requests found", style: GoogleFonts.poppins(color: Colors.grey)));

    return Row(
      children: [
        // Left Panel: List
        SizedBox(
          width: 350,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 16, 16),
                child: TextField(
                   decoration: InputDecoration(
                     hintText: 'Search by leave type...',
                     prefixIcon: const Icon(Icons.search),
                     filled: true,
                     fillColor: Theme.of(context).cardColor,
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                   ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 32, right: 16, bottom: 20),
                  itemCount: _leaves.length,
                  itemBuilder: (context, index) {
                    final leave = _leaves[index];
                    final isSelected = _selectedLeave == leave;
                    
                    Color statusColor = Colors.grey;
                    if (leave['status'] == 'Approved') statusColor = Colors.green;
                    if (leave['status'] == 'Rejected') statusColor = Colors.red;
                    if (leave['status'] == 'Pending') statusColor = Colors.orange;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedLeave = leave),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Theme.of(context).primaryColor.withOpacity(0.1) 
                              : Theme.of(context).cardColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) : Border.all(color: Colors.transparent),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                  Text(leave['leave_type'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text(leave['status'], style: GoogleFonts.poppins(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
                               ],
                             ),
                             const SizedBox(height: 8),
                             Text("${leave['start_date']}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Right Panel: Details
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 32, bottom: 32, left: 16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: _selectedLeave == null 
               ? const Center(child: Text("Select a leave request to view details"))
               : _buildLeaveDetailPanel(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveDetailPanel(BuildContext context) {
      Color statusColor = Colors.grey;
      if (_selectedLeave['status'] == 'Approved') statusColor = Colors.green;
      if (_selectedLeave['status'] == 'Rejected') statusColor = Colors.red;
      if (_selectedLeave['status'] == 'Pending') statusColor = Colors.orange;

      // Calculate duration roughly
      final start = DateTime.parse(_selectedLeave['start_date']);
      final end = DateTime.parse(_selectedLeave['end_date']);
      final duration = end.difference(start).inDays + 1;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Leave Request #${_selectedLeave['id']}", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Applied on: ${_selectedLeave['created_at'] ?? 'N/A'}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                 decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                 child: Row(
                   children: [
                     const Icon(Icons.circle, size: 8, color: Colors.white),
                     const SizedBox(width: 6),
                     Text(_selectedLeave['status'].toUpperCase(), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                   ],
                 ),
              )
            ],
          ),
          const SizedBox(height: 40),
          
          Text("LEAVE DETAILS", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          
          Row(
            children: [
               Expanded(
                 child: _buildDetailBox(context, "Type", _selectedLeave['leave_type']),
               ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
               Expanded(child: _buildDetailBox(context, "From", _selectedLeave['start_date'])),
               const SizedBox(width: 16),
               Expanded(child: _buildDetailBox(context, "To", _selectedLeave['end_date'])),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailBox(context, "Duration", "$duration Days", isHighlight: true),
          
          const SizedBox(height: 40),
           Text("JUSTIFICATION & REMARKS", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
           const SizedBox(height: 16),
           
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               border: Border.all(color: Colors.grey.withOpacity(0.3)),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     const Icon(Icons.comment, size: 16, color: Colors.grey),
                     const SizedBox(width: 8),
                     Text("Reason", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                   ],
                 ),
                 const SizedBox(height: 8),
                 Text('"${_selectedLeave['reason']}"', style: GoogleFonts.poppins(fontStyle: FontStyle.italic, fontSize: 15)),
               ],
             ),
           ),
           
           if (_selectedLeave['admin_remarks'] != null) ...[
             const SizedBox(height: 16),
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 border: Border.all(color: Colors.grey.withOpacity(0.3)),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text("Admin Remarks", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                   const SizedBox(height: 8),
                   Text(_selectedLeave['admin_remarks'], style: GoogleFonts.poppins(fontSize: 14)),
                 ],
               ),
             ),
           ]
        ],
      );
  }

  Widget _buildDetailBox(BuildContext context, String label, String value, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
        border: Border.all(color: isHighlight ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(color: isHighlight ? Theme.of(context).primaryColor : Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isHighlight ? Theme.of(context).primaryColor : null)),
        ],
      ),
    );
  }
}
