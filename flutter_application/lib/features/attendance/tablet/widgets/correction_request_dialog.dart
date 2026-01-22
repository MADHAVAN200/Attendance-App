import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/attendance_service.dart';
import '../../../../shared/services/auth_service.dart';

class CorrectionRequestDialog extends StatefulWidget {
  final int? attendanceId; // Optional, if correcting a specific record
  final DateTime? initialDate;

  const CorrectionRequestDialog({super.key, this.attendanceId, this.initialDate});

  static Future<void> show(BuildContext context, {int? attendanceId, DateTime? date}) {
    return showDialog(
      context: context,
      builder: (context) => CorrectionRequestDialog(attendanceId: attendanceId, initialDate: date),
    );
  }

  @override
  State<CorrectionRequestDialog> createState() => _CorrectionRequestDialogState();
}

class _CorrectionRequestDialogState extends State<CorrectionRequestDialog> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Correction',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today, size: 20),
                  ),
                  child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<String>(
                value: _correctionType,
                decoration: const InputDecoration(
                  labelText: 'Issue Type',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((t) {
                  return DropdownMenuItem(value: t['value'], child: Text(t['label']!));
                }).toList(),
                onChanged: (v) => setState(() => _correctionType = v!),
              ),
              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Justification / Comments',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? 'Please provide a reason' : null,
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit Request'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
