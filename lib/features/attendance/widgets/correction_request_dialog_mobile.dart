import 'package:flutter/material.dart';
import 'package:flutter_application/features/attendance/core/correction_request.dart'; // Add import for CorrectionType
import 'package:flutter_application/shared/widgets/toast_helper.dart';
import 'package:flutter_application/features/attendance/widgets/correction_request_form.dart';

class CorrectionRequestDialogMobile extends StatefulWidget {
  final int? attendanceId;
  final DateTime? initialDate;
  final CorrectionType? initialType; // Added

  const CorrectionRequestDialogMobile({
    super.key,
    this.attendanceId,
    this.initialDate,
    this.initialType,
  });

  static Future<void> show(
    BuildContext context, {
    int? attendanceId,
    DateTime? date,
    CorrectionType? type,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 500),
      builder: (context) => CorrectionRequestDialogMobile(
        attendanceId: attendanceId,
        initialDate: date,
        initialType: type,
      ),
    );

    if (result == true && context.mounted) {
       context.showToast("Your correction request has been sent for approval.", isSuccess: true);
    }
  }

  @override
  State<CorrectionRequestDialogMobile> createState() => _CorrectionRequestDialogMobileState();
}

class _CorrectionRequestDialogMobileState extends State<CorrectionRequestDialogMobile> {

  @override
  Widget build(BuildContext context) {
    return CorrectionRequestForm(
      initialDate: widget.initialDate,
      initialType: widget.initialType, // Pass to form
      onClose: () => Navigator.pop(context),
      onSuccess: () {
        Navigator.pop(context, true);
      },
    );
  }
}



// [upd:2026-04-16T14:00:00+05:30]
