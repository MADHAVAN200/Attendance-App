import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/attendance_service.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../features/leave/widgets/custom_date_picker_dialog.dart';
import '../../../../shared/widgets/custom_dialog.dart';

class CorrectionRequestDialogMobile extends StatefulWidget {
  final int? attendanceId;
  final DateTime? initialDate;

  const CorrectionRequestDialogMobile({super.key, this.attendanceId, this.initialDate});

  static Future<void> show(BuildContext context, {int? attendanceId, DateTime? date}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CorrectionRequestDialogMobile(attendanceId: attendanceId, initialDate: date),
    );

    if (result == true && context.mounted) {
       await CustomDialog.show(
          context: context,
          title: "Request Submitted",
          message: "Your correction request has been sent for approval.",
          icon: Icons.check_circle,
          iconColor: const Color(0xFF10B981),
          positiveButtonText: "Done",
          positiveButtonColor: const Color(0xFF10B981),
          onPositivePressed: () => Navigator.pop(context),
       );
    }
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
        Navigator.pop(context, true); // Return true to trigger success dialog
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
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey : const Color(0xFF64748B); // Slate 500
    final inputFillColor = isDark ? Colors.transparent : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0); // Slate 200

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
                          color: textColor,
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
                  Text("DATE", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDialog<DateTime>(
                        context: context,
                        builder: (context) => CustomDatePickerDialog(
                          initialDate: _selectedDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime.now(),
                        ),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                        color: inputFillColor,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 18, color: labelColor),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
        
                  // Type
                  Text("ISSUE TYPE", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _correctionType,
                    style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5B60F6))),
                      filled: true,
                      fillColor: inputFillColor,
                    ),
                    dropdownColor: isDark ? const Color(0xFF1E2939) : Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down, color: labelColor),
                    items: _types.map((t) {
                      return DropdownMenuItem(value: t['value'], child: Text(t['label']!));
                    }).toList(),
                    onChanged: (v) => setState(() => _correctionType = v!),
                  ),
                  const SizedBox(height: 16),
        
                  // Reason
                  Text("JUSTIFICATION / COMMENTS", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _reasonController,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    style: GoogleFonts.poppins(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Explain why you are requesting this...',
                      hintStyle: GoogleFonts.poppins(color: labelColor, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5B60F6))),
                      filled: true,
                      fillColor: inputFillColor,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please provide a reason' : null,
                  ),
                  const SizedBox(height: 24),
        
                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B60F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Submit Request', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
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
