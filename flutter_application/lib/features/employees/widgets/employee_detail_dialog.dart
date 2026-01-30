import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../models/employee_model.dart';

class EmployeeDetailDialog extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailDialog({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    // Determine screen width to switch between mobile and tablet/desktop layouts
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GlassContainer(
        width: isMobile ? double.infinity : 450,
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: isMobile 
            ? _buildMobileLayout(context, isDark)
            : _buildDesktopLayout(context, isDark),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(context, isDark, 40),
        const SizedBox(height: 16),
        Text(
          employee.userName, 
          style: GoogleFonts.poppins(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: isDark ? Colors.white : null
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          employee.designation ?? 'N/A', 
          style: GoogleFonts.poppins(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        Divider(height: 32, color: isDark ? Colors.white24 : null),
        _buildDetailRow(context, Icons.email_outlined, 'Email', employee.email, isDark),
        const SizedBox(height: 12),
        _buildDetailRow(context, Icons.phone_outlined, 'Phone', employee.phoneNo ?? 'N/A', isDark),
        const SizedBox(height: 12),
        _buildDetailRow(context, Icons.work_outline, 'Department', employee.department ?? 'N/A', isDark),
        const SizedBox(height: 12),
        _buildDetailRow(context, Icons.access_time, 'Shift', employee.shift ?? 'N/A', isDark),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF4338CA) : Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildAvatar(context, isDark, 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.userName, 
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : null)
                  ),
                  Text(
                    employee.designation ?? 'N/A', 
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)
                  ),
                ],
              ),
            ),
            IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: isDark ? Colors.white70 : null)),
          ],
        ),
        const SizedBox(height: 24),
        _buildDetailRow(context, Icons.email_outlined, 'Email', employee.email, isDark),
        const SizedBox(height: 16),
        _buildDetailRow(context, Icons.phone_outlined, 'Phone', employee.phoneNo ?? 'N/A', isDark),
        const SizedBox(height: 16),
        _buildDetailRow(context, Icons.work_outline, 'Department', employee.department ?? 'N/A', isDark),
        const SizedBox(height: 16),
        _buildDetailRow(context, Icons.access_time, 'Shift', employee.shift ?? 'N/A', isDark),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF4338CA) : Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, bool isDark, double radius) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isDark ? Border.all(color: const Color(0xFF4338CA), width: 2) : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: isDark ? const Color(0xFF101828) : Theme.of(context).primaryColor.withValues(alpha: 0.15),
        child: Text(
          employee.userName.isNotEmpty ? employee.userName[0].toUpperCase() : '?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Theme.of(context).primaryColor,
            fontSize: radius * 0.75, // Responsive text size
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text(
                value, 
                style: GoogleFonts.poppins(
                  fontSize: 14, 
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : null
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}
