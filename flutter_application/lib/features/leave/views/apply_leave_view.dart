import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../shared/services/auth_service.dart';
import '../../holidays/services/holiday_service.dart';
import '../../holidays/models/holiday_model.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';
import '../mobile/views/apply_leave_mobile.dart';
import '../tablet/views/apply_leave_tablet.dart';

class ApplyLeaveView extends StatefulWidget {
  const ApplyLeaveView({super.key});

  @override
  State<ApplyLeaveView> createState() => ApplyLeaveViewState();
}

class ApplyLeaveViewState extends State<ApplyLeaveView> {
  // Services
  late LeaveService _leaveService;
  late HolidayService _holidayService;

  // Data
  List<Leave> leaves = [];
  List<Holiday> holidays = [];
  Map<String, int> stats = {
    'totalApplied': 0,
    'approved': 0,
    'pending': 0,
    'rejected': 0,
  };

  // UI State
  bool isLoading = true;
  bool isSubmitting = false;
  DateTime currentDate = DateTime.now();

  // Form Data
  final formKey = GlobalKey<FormState>();
  final subjectController = TextEditingController();
  final reasonController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  File? selectedDocument;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _leaveService = LeaveService(authService);
    // Assuming HolidayService is available via Provider or constructed similarly (usually centralized)
    // For now, constructing it manually using same Dio instance
    _holidayService = HolidayService(authService.dio); 
    
    _loadInitialData();
  }

  @override
  void dispose() {
    subjectController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        _leaveService.getMyLeaves(),
        _holidayService.getHolidays(),
      ]);

      if (mounted) {
        setState(() {
          leaves = results[0] as List<Leave>;
          holidays = results[1] as List<Holiday>;
          _calculateStats();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
        setState(() => isLoading = false);
      }
    }
  }

  void _calculateStats() {
    int total = 0, approved = 0, pending = 0, rejected = 0;
    for (var leave in leaves) {
      total++;
      if (leave.status == 'Approved') approved++;
      else if (leave.status == 'Pending') pending++;
      else if (leave.status == 'Rejected') rejected++;
    }
    stats = {
      'totalApplied': total,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
    };
  }

  // Calendar Logic
  void changeMonth(int offset) {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + offset, 1);
    });
  }

  void onDateTap(DateTime date) {
    // Normalizing time to midnight for comparison
    final clickedDate = DateTime(date.year, date.month, date.day);

    setState(() {
      if (startDate == null || (startDate != null && endDate != null)) {
        // Start selection
        startDate = clickedDate;
        endDate = null;
      } else {
        // End selection
        if (clickedDate.isBefore(startDate!)) {
          startDate = clickedDate;
          endDate = null;
        } else {
          endDate = clickedDate;
        }
      }
    });
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedDocument = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date range')));
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final leaveData = {
        'leave_type': subjectController.text, // Mapping subject to type as per requirement
        'start_date': startDate!.toIso8601String().split('T')[0],
        'end_date': endDate!.toIso8601String().split('T')[0],
        'reason': reasonController.text,
      };

      await _leaveService.applyForLeave(leaveData, document: selectedDocument);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request submitted')));
        // Reset form
        subjectController.clear();
        reasonController.clear();
        setState(() {
          startDate = null;
          endDate = null;
          selectedDocument = null;
        });
        _loadInitialData(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> withdrawLeave(int id) async {
    try {
      await _leaveService.withdrawLeave(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave withdrawn')));
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return ApplyLeaveMobile(controller: this);
        } else {
          return ApplyLeaveTablet(controller: this);
        }
      },
    );
  }
}
