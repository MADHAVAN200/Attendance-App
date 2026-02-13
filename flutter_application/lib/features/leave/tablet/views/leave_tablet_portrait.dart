import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../providers/leave_provider.dart';
import '../../../holidays/services/holiday_service.dart';
import '../../widgets/holiday_details_dialog.dart';
import '../../widgets/leave_history_item.dart';
import '../../widgets/leave_request_form.dart';
import '../../widgets/admin_leave_view.dart';
import '../../../holidays/widgets/holiday_form_dialog.dart'; // Import Form
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../holidays/models/holiday_model.dart'; // Import Model

class LeaveTabletPortrait extends StatefulWidget {
  const LeaveTabletPortrait({super.key});

  @override
  State<LeaveTabletPortrait> createState() => _LeaveTabletPortraitState();
}

class _LeaveTabletPortraitState extends State<LeaveTabletPortrait> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HolidayService _holidayService;
  
  bool _isLoadingHolidays = false;
  List<dynamic> _holidays = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _isAdmin = authService.user?.isAdmin ?? false;

    _tabController = TabController(length: _isAdmin ? 3 : 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = authService.dio;
      _holidayService = HolidayService(dio);
      
      _fetchHolidays();
      // Fetch leaves via provider
      context.read<LeaveProvider>().fetchMyLeaves();
    });
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

  void _showApplyLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: LeaveRequestForm(
            onSuccess: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Leave Requested Successfully")),
              );
              context.read<LeaveProvider>().fetchMyLeaves();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _withdrawRequest(int id) async {
    try {
      final confirm = await CustomDialog.show(
        context: context,
        title: "Withdraw Request",
        message: "Are you sure you want to withdraw this leave request? This action cannot be undone.",
        positiveButtonText: "Withdraw",
        negativeButtonText: "Cancel",
        isDestructive: true,
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.red,
        onPositivePressed: () {},
      );

      if (confirm == true && mounted) {
        await context.read<LeaveProvider>().withdrawRequest(id);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Withdrawn Successfully")));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Withdraw Failed: $e")));
    }
  }

  // Admin Actions
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => HolidayFormDialog(
        onSubmit: (data) async {
          try {
            await _holidayService.addHoliday(data);
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            _fetchHolidays();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Holiday Added")));
            }
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
      ),
    );
  }

  void _showEditDialog(Holiday holiday) {
    showDialog(
      context: context,
      builder: (ctx) => HolidayFormDialog(
        initialData: holiday,
        onSubmit: (data) async {
          try {
            await _holidayService.updateHoliday(holiday.id, data);
            if (!ctx.mounted) return;
            Navigator.pop(ctx);
            _fetchHolidays();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Holiday Updated")));
            }
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
      ),
    );
  }

  Future<void> _deleteHoliday(int id) async {
    try {
      await _holidayService.deleteHolidays([id]);
      _fetchHolidays();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
      }
    }
  }

  void _showDeleteConfirm(int id) {
    CustomDialog.show(
      context: context,
      title: "Delete Holiday?",
      message: "Are you sure you want to delete this holiday?",
      positiveButtonText: "Delete",
      isDestructive: true,
      onPositivePressed: () {
        Navigator.pop(context);
        _deleteHoliday(id);
      },
      negativeButtonText: "Cancel",
      onNegativePressed: () => Navigator.pop(context),
      icon: Icons.delete_outline,
      iconColor: Colors.red,
    );
  }

  Future<void> _importCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final input = file.openRead();
        final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

        if (fields.isEmpty) return;

        // Expect contents: Name, Date, Type
        // Skip header if first row looks like header
        int startRow = 0;
        if (fields[0].isNotEmpty && fields[0][0].toString().toLowerCase().contains('name')) {
          startRow = 1;
        }

        final List<Map<String, dynamic>> batch = [];
        for (int i = startRow; i < fields.length; i++) {
          final row = fields[i];
          if (row.length < 2) continue; // Skip invalid rows

          // Safe row access
          final name = row[0].toString();
          // Date Parsing: Try to handle YYYY-MM-DD
          final date = row[1].toString(); 
          final type = row.length > 2 ? row[2].toString() : 'Public';
          
          if (name.isNotEmpty && date.isNotEmpty) {
             batch.add({
               "holiday_name": name,
               "holiday_date": date,
               "holiday_type": type,
             });
          }
        }

        if (batch.isNotEmpty) {
          setState(() => _isLoadingHolidays = true);
          await _holidayService.addBulkHolidays(batch);
          _fetchHolidays();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imported ${batch.length} holidays")));
          }
        } else {
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No valid data found in CSV")));
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Import Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoadingHolidays = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showFab = false;
    // Admin: Show "Add Holiday" on Tab 0 (Holidays)
    if (_isAdmin && _tabController.index == 0) {
      showFab = true;
    }
    // "Apply Leave" on Tab 1 (My Leaves)
    else if (_tabController.index == 1) {
      showFab = true;
    }

    return Scaffold(
      floatingActionButton: showFab
        ? FloatingActionButton.extended(
            onPressed: () {
               if (_isAdmin && _tabController.index == 0) {
                 _showAddDialog();
               } else {
                 _showApplyLeaveDialog();
               }
            },
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 4,
            icon: Icon((_isAdmin && _tabController.index == 0) ? Icons.add : Icons.add, color: Colors.white),
            label: Text(
              (_isAdmin && _tabController.index == 0) ? "Add Holiday" : "Apply Leave", 
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)
            ),
          )
        : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildTabs(context),
                  if (_isAdmin && _tabController.index == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _importCSV,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text("Bulk Import"),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHolidaysList(context),
            _buildLeaveList(context),
            if (_isAdmin) AdminLeaveView(),
          ],
        ),
      ),
    );
  }

  bool _shouldShowFab() {
     // Replaced by inline logic in build
     return false; 
  }

  Widget _buildTabs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF5B60F6),
        unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: [
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 16),
                SizedBox(width: 8),
                Text("Holidays List"),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description_outlined, size: 16),
                SizedBox(width: 8),
                Text("My Leaves"),
              ],
            ),
          ),
          if (_isAdmin)
             const Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 16),
                  SizedBox(width: 8),
                  Text("Requests"),
                ],
              ),
            ),
        ],
      ),
    );
  }



  void _showHolidayOptions(BuildContext context, Holiday holiday) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2939) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                  title: Text(
                    'Edit Holiday',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1E2939),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(holiday);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                  title: Text(
                    'Delete Holiday',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1E2939),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirm(holiday.id);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHolidaysList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoadingHolidays) return const Center(child: CircularProgressIndicator());
    if (_holidays.isEmpty) return Center(child: Text("No holidays found", style: GoogleFonts.poppins(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 80),
      itemCount: _holidays.length,
      itemBuilder: (context, index) {
        final holiday = _holidays[index];
        final dt = DateTime.parse(holiday.date);
        
        return InkWell(
          onTap: () => HolidayDetailsDialog.showPortrait(context, holiday: holiday),
          child: GlassContainer(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d').format(dt), 
                        style: GoogleFonts.poppins(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: isDark ? Colors.white : Theme.of(context).primaryColor
                        )
                      ),
                      Text(
                        DateFormat('MMM').format(dt).toUpperCase(), 
                        style: GoogleFonts.poppins(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: isDark ? Colors.white70 : Theme.of(context).primaryColor
                        )
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holiday.name, 
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, 
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87
                        )
                      ),
                      Text(
                        DateFormat('EEEE').format(dt), 
                        style: GoogleFonts.poppins(
                          fontSize: 12, 
                          color: isDark ? Colors.grey[400] : Colors.grey
                        )
                      ),
                    ],
                  ),
                ),
                if (_isAdmin)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showHolidayOptions(context, holiday),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveList(BuildContext context) {
    return Consumer<LeaveProvider>(
      builder: (context, provider, _) {
         if (provider.isLoadingMyLeaves) return const Center(child: CircularProgressIndicator());
         if (provider.myLeavesError != null) return Center(child: Text('Error: ${provider.myLeavesError}'));
         if (provider.myLeaves.isEmpty) return Center(child: Text("No leave requests found", style: GoogleFonts.poppins(color: Colors.grey)));

         return RefreshIndicator(
            onRefresh: () => provider.fetchMyLeaves(forceRefresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: provider.myLeaves.length,
              itemBuilder: (context, index) {
                final request = provider.myLeaves[index];
                return LeaveHistoryItem(
                  request: request,
                  onDelete: () => _withdrawRequest(request.id),
                );
              },
            ),
         );
      },
    );
  }
}
