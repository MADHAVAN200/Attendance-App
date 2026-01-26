import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/attendance_service.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_date_picker.dart';

class CorrectionRequestDialogMobile extends StatefulWidget {
  final int? attendanceId;
  final DateTime? initialDate;

  const CorrectionRequestDialogMobile({super.key, this.attendanceId, this.initialDate});

  static Future<void> show(BuildContext context, {int? attendanceId, DateTime? date}) {
    return showDialog(
      context: context,
      builder: (context) => CorrectionRequestDialogMobile(attendanceId: attendanceId, initialDate: date),
    );
  }

  @override
  State<CorrectionRequestDialogMobile> createState() => _CorrectionRequestDialogMobileState();
}

class _CorrectionRequestDialogMobileState extends State<CorrectionRequestDialogMobile> {
  final _formKey = GlobalKey<FormState>();
  
  late String _correctionType;
  late TextEditingController _reasonController;
  late DateTime _selectedDate;
  
  bool _isLoading = false;

  final List<Map<String, String>> _types = [
    {'value': 'missed_punch', 'label': 'Missed Punch'},
    {'value': 'late_entry', 'label': 'Late Entry (System Issue)'},
    {'value': 'early_exit', 'label': 'Early Exit (Approved)'},
    {'value': 'wrong_location', 'label': 'Wrong Location'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _correctionType = 'missed_punch';
    _reasonController = TextEditingController();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final service = AttendanceService(authService.dio);

      await service.createCorrectionRequest(
        attendanceId: widget.attendanceId,
        correctionType: _correctionType,
        requestDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mobile optimization: Use SingleChildScrollView to avoid overflow
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Request Correction',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Theme.of(context).disabledColor),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Date
                  InkWell(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => GlassDatePicker(
                          initialDate: _selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime.now(),
                          onDateSelected: (newDate) {
                            setState(() => _selectedDate = newDate);
                          },
                        ),
                      );
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: GoogleFonts.poppins(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
        
                  // Type
                  DropdownButtonFormField<String>(
                    value: _correctionType,
                    decoration: InputDecoration(
                      labelText: 'Issue Type',
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _types.map((t) {
                      return DropdownMenuItem(value: t['value'], child: Text(t['label']!, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (v) => setState(() => _correctionType = v!),
                  ),
                  const SizedBox(height: 16),
        
                  // Reason
                  TextFormField(
                    controller: _reasonController,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Justification / Comments',
                      labelStyle: GoogleFonts.poppins(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please provide a reason' : null,
                  ),
                  const SizedBox(height: 24),
        
                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B60F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Submit Request', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
