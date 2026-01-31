import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class HolidaySuccessDialog extends StatelessWidget {
  final String title;
  final String message;

  const HolidaySuccessDialog({
    super.key,
    required this.title,
    required this.message,
  });

  static Future<void> show(BuildContext context, {String? title, String? message}) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => HolidaySuccessDialog(
        title: title ?? "Success!",
        message: message ?? "Operation completed successfully.",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF6366F1); // Purple/Indigo to match Holiday Theme
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
                  Icons.calendar_today_rounded,
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

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    shadowColor: color.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    "Done",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
