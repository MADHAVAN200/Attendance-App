import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../services/auth_service.dart';
import '../../../../shared/models/holiday_model.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../../services/policy_service.dart';
import '../../../../services/leave_service.dart';
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
  late PolicyService _policyService;

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
    // Initialize Services
    _leaveService = LeaveService();
    _policyService = PolicyService();
    
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
        _leaveService.getMyLeaveHistory(),
        _policyService.getHolidays(),
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
    final clickedDate = DateTime(date.year, date.month, date.day);

    setState(() {
      if (startDate == null || (startDate != null && endDate != null)) {
        startDate = clickedDate;
        endDate = null;
      } else {
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
      await _leaveService.submitLeaveRequest(
        leaveType: subjectController.text,
        startDate: startDate!.toIso8601String().split('T')[0],
        endDate: endDate!.toIso8601String().split('T')[0],
        reason: reasonController.text,
        document: selectedDocument
      );
      
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
      await _leaveService.withdrawRequest(id);
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
