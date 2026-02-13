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
import '../../widgets/leave_calendar.dart';
import '../../widgets/leave_request_form.dart';
import '../../widgets/holiday_details_dialog.dart';
import '../../widgets/leave_history_item.dart';
import '../../widgets/admin_leave_view.dart';
import '../../../holidays/widgets/holiday_form_dialog.dart'; // Import Form
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../holidays/models/holiday_model.dart'; // Import Model

class LeaveTabletLandscape extends StatefulWidget {
  const LeaveTabletLandscape({super.key});

  @override
  State<LeaveTabletLandscape> createState() => _LeaveTabletLandscapeState();
}

class _LeaveTabletLandscapeState extends State<LeaveTabletLandscape> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HolidayService _holidayService;
  
  bool _isLoadingHolidays = false;
  List<dynamic> _holidays = [];
  bool _isAdmin = false;
  
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel: Content (Flex 1)
          Expanded(
            flex: 1,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildTabs(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Holidays List
                  _buildHolidaysView(context),
                  // Tab 2: Leave Application (Form + History)
                  _buildLeaveApplicationView(context),
                  // Tab 3: Admin Requests
                  if (_isAdmin) AdminLeaveView(),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Right Panel: Calendar (Flex 1)
          Expanded(
            flex: 1,
            child: Consumer<LeaveProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      // Calendar Widget
                      LeaveCalendar(
                        holidays: _holidays,
                        leaves: provider.myLeaves.map((l) => l.toJson()).toList(), // Convert back to dynamic/map for calendar if needed, or update calendar to accept LeaveRequest
                        focusedDay: _focusedMonth,
                        onMonthChanged: (d) => setState(() => _focusedMonth = d),
                        rangeStart: _selectedStartDate, 
                        rangeEnd: _selectedEndDate,     
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                  Text("Holidays"),
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

  Widget _buildHolidaysView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E2939) : Colors.white;
    final borderColor = isDark ? Colors.transparent : Colors.grey[200]!;

    return Column(
      children: [
          Container(
             width: double.infinity,
             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
             decoration: BoxDecoration(
               color: cardColor,
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: isDark ? Colors.transparent : Colors.grey[200]!),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text(
                   DateFormat('MMMM yyyy').format(_focusedMonth),
                   style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                 ),
                 if (_isAdmin)
                  Row(
                    children: [
                       TextButton.icon(
                         onPressed: _importCSV,
                         icon: const Icon(Icons.upload_file, size: 18),
                         label: const Text("Import CSV"),
                         style: TextButton.styleFrom(
                           foregroundColor: isDark ? Colors.white70 : Colors.indigo,
                         ),
                       ),
                       const SizedBox(width: 8),
                       IconButton(
                         onPressed: _showAddDialog,
                         icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1), size: 28),
                         tooltip: "Add Holiday",
                       ),
                    ],
                  ),
               ],
             ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _holidays.isEmpty 
              ? Center(child: _isLoadingHolidays ? const CircularProgressIndicator() : const Text("No holidays"))
              : ListView.separated(
                  itemCount: _holidays.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final holiday = _holidays[index];
                    final dt = DateTime.parse(holiday.date);
                    
                    if (dt.month != _focusedMonth.month || dt.year != _focusedMonth.year) {
                      return const SizedBox.shrink(); 
                    }

                    return InkWell(
                      onTap: () => HolidayDetailsDialog.showLandscape(context, holiday: holiday),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF6366F1).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                   children: [
                                      Text(
                                        DateFormat('dd').format(dt), 
                                        style: GoogleFonts.poppins(
                                          fontSize: 20, 
                                          fontWeight: FontWeight.bold, 
                                          color: isDark ? Colors.white : const Color(0xFF6366F1)
                                        )
                                      ),
                                      Text(
                                        DateFormat('EEE').format(dt).toUpperCase(), 
                                        style: GoogleFonts.poppins(
                                          fontSize: 11, 
                                          fontWeight: FontWeight.w600, 
                                          color: isDark ? Colors.white70 : const Color(0xFF6366F1)
                                        )
                                      ),
                                   ],
                                ),
                              ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(holiday.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
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
                ),
          ),
      ],
    );
  }

  Widget _buildLeaveApplicationView(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use new LeaveRequestForm
          // LeaveRequestForm is designed as a card/sheet. We can just wrap it.
          // It handles submission and then calls onSuccess.
          // onSuccess we refresh leaves.
          
          LeaveRequestForm(
            onSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Leave Requested Successfully")));
              context.read<LeaveProvider>().fetchMyLeaves();
            },
          ),
          
          const SizedBox(height: 32),
          Text("Leave History", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          
          Consumer<LeaveProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingMyLeaves) return const Center(child: CircularProgressIndicator());
              if (provider.myLeaves.isEmpty) return const Text("No records.");

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.myLeaves.length,
                itemBuilder: (context, index) {
                  final request = provider.myLeaves[index];
                  // Use LeaveHistoryItem
                  return LeaveHistoryItem(
                    request: request,
                    onDelete: () => _withdrawRequest(request.id),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
