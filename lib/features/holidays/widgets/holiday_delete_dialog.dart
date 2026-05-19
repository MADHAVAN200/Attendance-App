import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class HolidayDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const HolidayDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  static Future<void> show(BuildContext context, {required String title, required String message, required VoidCallback onConfirm}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => HolidayDeleteDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFEF4444); // Red for delete
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox( // Limit width for landscape
        constraints: const BoxConstraints(maxWidth: 450),
        child: GlassContainer(
          padding: EdgeInsets.all(isLandscape ? 24 : 32),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon / Illustration
              Container(
                padding: EdgeInsets.all(isLandscape ? 12 : 20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ]
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  size: isLandscape ? 32 : 48,
                  color: color,
                ),
              ),
              SizedBox(height: isLandscape ? 16 : 24),
              
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isLandscape ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: isLandscape ? 16 : 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey,
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        shadowColor: color.withValues(alpha: 0.5),
                      ),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
