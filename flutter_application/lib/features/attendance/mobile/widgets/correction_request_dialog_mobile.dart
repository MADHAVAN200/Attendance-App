import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/attendance_service.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../features/leave/widgets/custom_date_picker_dialog.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../widgets/correction_request_form.dart';

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

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Dialog(
      backgroundColor: Colors.transparent, // Transparent for Glass effect
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400), // Slimmer width
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(0), // Padding handled by form/header internally
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Request Correction',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
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
              ),
              
              const SizedBox(height: 8),

              // Use the Shared Form Component
              // Constrained height or just standard? Form is Scrollable.
              // Since it's in a Dialog + Column, we need Flexible or Expanded.
              // Mobile might need specific height constraint if content is long.
              // Previous code used SizedBox(height: 500).
              // Let's use Flexible with a max constraints or just Flexible.
              Flexible(
                child: CorrectionRequestForm(
                  initialDate: widget.initialDate,
                  onSuccess: () {
                     Navigator.pop(context, true); // Success
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


