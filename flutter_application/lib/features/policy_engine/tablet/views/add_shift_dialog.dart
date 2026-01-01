import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class AddShiftDialog extends StatefulWidget {
  const AddShiftDialog({super.key});

  @override
  State<AddShiftDialog> createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<AddShiftDialog> {
  bool _isOvertimeEnabled = false;
  String _selectedShiftType = 'Fixed Time';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Shift',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Scrollable Area
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shift Name
                      _buildLabel(context, 'Shift Name'),
                      _buildTextField(context, 'e.g. Morning Shift A'),
                      const SizedBox(height: 16),

                      // Shift Type
                      _buildLabel(context, 'Shift Type'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8),
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedShiftType,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodySmall?.color),
                            dropdownColor: backgroundColor,
                            items: ['Fixed Time', 'Rotational', 'Night Shift']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e, style: GoogleFonts.poppins(fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedShiftType = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Pickers
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'Start Time'),
                                _buildTimePicker(context, '--:--'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(context, 'End Time'),
                                _buildTimePicker(context, '--:--'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grace Period
                      _buildLabel(context, 'Grace Period (Minutes)'),
                      _buildTextField(context, '0', suffixText: 'mins'),
                      const SizedBox(height: 4),
                      Text(
                        'Time allowed after start time before marking as "Late".',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // Overtime Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overtime Calculation',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Enable automatic OT tracking',
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isOvertimeEnabled,
                            onChanged: (v) => setState(() => _isOvertimeEnabled = v),
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                      
                      if (_isOvertimeEnabled) ...[
                         const SizedBox(height: 16),
                         _buildLabel(context, 'Minimum Hours for OT'),
                         _buildTextField(context, '8', suffixText: 'hours'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B60F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Save Shift',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String hint, {String? suffixText}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;

    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        suffixText: suffixText,
        suffixStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        filled: true,
      ),
      style: GoogleFonts.poppins(fontSize: 14),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildTimePicker(BuildContext context, String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hint,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
            Icon(Icons.access_time, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
