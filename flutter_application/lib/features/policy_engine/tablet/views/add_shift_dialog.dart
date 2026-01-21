import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/models/shift_model.dart';

class AddShiftDialog extends StatefulWidget {
  final Shift? existingShift;
  final Function(Shift) onSubmit;
  
  const AddShiftDialog({super.key, this.existingShift, required this.onSubmit});

  @override
  State<AddShiftDialog> createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<AddShiftDialog> {
  final _nameCtrl = TextEditingController();
  final _graceCtrl = TextEditingController(text: "0");
  final _otThresholdCtrl = TextEditingController(text: "8.0");
  
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isOvertimeEnabled = false;
  String _selectedShiftType = 'Fixed Time';
  
  // New Fields
  List<String> _selectedDays = ["Mon", "Tue", "Wed", "Thu", "Fri"];
  bool _alternateSatEnabled = false;
  List<int> _alternateSatOff = []; // [2, 4]
  
  bool _entrySelfie = true;
  bool _entryGeofence = true;
  bool _exitSelfie = false;
  bool _exitGeofence = false;

  final List<String> _weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    if (widget.existingShift != null) {
      final s = widget.existingShift!;
      _nameCtrl.text = s.name;
      _graceCtrl.text = s.gracePeriodMins.toString();
      _isOvertimeEnabled = s.isOvertimeEnabled;
      _otThresholdCtrl.text = s.overtimeThresholdHours.toString();
      _startTime = _parseTime(s.startTime);
      _endTime = _parseTime(s.endTime);
      
      _selectedDays = List.from(s.workingDays);
      _alternateSatEnabled = s.alternateSaturdays.enabled;
      _alternateSatOff = List.from(s.alternateSaturdays.off);
      
      _entrySelfie = s.policyRules.entryRequirements.selfie;
      _entryGeofence = s.policyRules.entryRequirements.geofence;
      _exitSelfie = s.policyRules.exitRequirements.selfie;
      _exitGeofence = s.policyRules.exitRequirements.geofence;
    }
  }

  TimeOfDay _parseTime(String t) {
      try {
        final parts = t.split(":");
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        return const TimeOfDay(hour: 9, minute: 0);
      }
  }
   
  String _fmtTime(TimeOfDay t) {
     final h = t.hour.toString().padLeft(2, '0');
     final m = t.minute.toString().padLeft(2, '0');
     return "$h:$m";
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context, 
      initialTime: isStart ? _startTime : _endTime
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shift Name is required")));
      return;
    }
    
    // Construct Policy Rules
    final shiftTiming = ShiftTiming(startTime: _fmtTime(_startTime), endTime: _fmtTime(_endTime));
    final grace = GracePeriod(minutes: int.tryParse(_graceCtrl.text) ?? 0);
    final ot = Overtime(enabled: _isOvertimeEnabled, threshold: double.tryParse(_otThresholdCtrl.text) ?? 8.0);
    final entry = EntryRequirements(selfie: _entrySelfie, geofence: _entryGeofence);
    final exit = ExitRequirements(selfie: _exitSelfie, geofence: _exitGeofence);
    final policyRules = PolicyRules(
      shiftTiming: shiftTiming, 
      gracePeriod: grace, 
      overtime: ot, 
      entryRequirements: entry, 
      exitRequirements: exit
    );
    
    final s = Shift(
      id: widget.existingShift?.id,
      name: _nameCtrl.text,
      startTime: _fmtTime(_startTime),
      endTime: _fmtTime(_endTime),
      gracePeriodMins: grace.minutes,
      isOvertimeEnabled: _isOvertimeEnabled,
      overtimeThresholdHours: ot.threshold,
      workingDays: _selectedDays,
      alternateSaturdays: AlternateSaturdays(enabled: _alternateSatEnabled, off: _alternateSatOff),
      policyRules: policyRules,
    );
    widget.onSubmit(s);
  }

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
        constraints: const BoxConstraints(maxWidth: 600),
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
                    widget.existingShift == null ? 'Create New Shift' : 'Edit Shift',
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
                      _buildTextField(context, 'e.g. Morning Shift A', controller: _nameCtrl),
                      const SizedBox(height: 16),
                      
                      // Shift Type Dropdown
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
                      const SizedBox(height: 24),

                      // Time Pickers
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                _buildLabel(context, 'Start Time'), 
                                _buildTimePicker(context, _fmtTime(_startTime), () => _pickTime(true))
                              ]
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                _buildLabel(context, 'End Time'), 
                                _buildTimePicker(context, _fmtTime(_endTime), () => _pickTime(false))
                              ]
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Working Days
                      _buildLabel(context, 'Working Days'),
                      Wrap(
                        spacing: 8,
                        children: _weekDays.map((day) {
                          final isSelected = _selectedDays.contains(day);
                          return FilterChip(
                            label: Text(day),
                            selected: isSelected,
                            onSelected: (v) {
                                setState(() {
                                  if (v) {
                                    _selectedDays.add(day);
                                  } else {
                                    _selectedDays.remove(day);
                                  }
                                });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Alternate Saturdays
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text("Alternate Saturdays Off", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                           Switch(value: _alternateSatEnabled, onChanged: (v) => setState(() => _alternateSatEnabled = v)),
                        ],
                      ),
                      if (_alternateSatEnabled) ...[
                        const SizedBox(height: 8),
                         Wrap(
                          spacing: 8,
                          children: [1, 2, 3, 4, 5].map((week) {
                            final isSelected = _alternateSatOff.contains(week);
                            return ChoiceChip(
                              label: Text("Sat $week"),
                              selected: isSelected,
                              onSelected: (v) {
                                setState(() {
                                  if (v) _alternateSatOff.add(week);
                                  else _alternateSatOff.remove(week);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Requirements Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Validation Requirements", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Entry", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                                      CheckboxListTile(
                                        title: const Text("Selfie", style: TextStyle(fontSize: 13)),
                                        value: _entrySelfie,
                                        onChanged: (v) => setState(() => _entrySelfie = v!),
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        dense: true,
                                      ),
                                      CheckboxListTile(
                                        title: const Text("Geofence", style: TextStyle(fontSize: 13)),
                                        value: _entryGeofence,
                                        onChanged: (v) => setState(() => _entryGeofence = v!),
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        dense: true,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Exit", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                                      CheckboxListTile(
                                        title: const Text("Selfie", style: TextStyle(fontSize: 13)),
                                        value: _exitSelfie,
                                        onChanged: (v) => setState(() => _exitSelfie = v!),
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        dense: true,
                                      ),
                                      CheckboxListTile(
                                        title: const Text("Geofence", style: TextStyle(fontSize: 13)),
                                        value: _exitGeofence,
                                        onChanged: (v) => setState(() => _exitGeofence = v!),
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        dense: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grace Period
                      _buildLabel(context, 'Grace Period (Minutes)'),
                      _buildTextField(context, '0', suffixText: 'mins', controller: _graceCtrl, isNumeric: true),
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
                         _buildTextField(context, '8', suffixText: 'hours', controller: _otThresholdCtrl, isNumeric: true),
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
                      onPressed: _submit,
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

  Widget _buildTextField(BuildContext context, String hint, {String? suffixText, TextEditingController? controller, bool isNumeric = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;

    return TextField(
      controller: controller,
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
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _buildTimePicker(BuildContext context, String value, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!;

    return InkWell(
      onTap: onTap,
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
              value,
              style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
            ),
            const Icon(Icons.access_time, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
