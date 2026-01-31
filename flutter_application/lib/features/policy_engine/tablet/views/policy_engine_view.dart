import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/glass_confirmation_dialog.dart';
import '../../../../shared/widgets/glass_success_dialog.dart';
import '../../../../shared/services/auth_service.dart';
import '../../models/shift_model.dart';
import '../../services/shift_service.dart';
import 'add_shift_dialog.dart';
import 'shift_detail_dialog.dart';
import '../../widgets/shift_action_sheet.dart';

class PolicyEngineView extends StatefulWidget {
  const PolicyEngineView({super.key});

  @override
  State<PolicyEngineView> createState() => _PolicyEngineViewState();
}

class _PolicyEngineViewState extends State<PolicyEngineView> {
  late ShiftService _shiftService;

  List<Shift> _shifts = [];
  bool _isLoadingShifts = true;

  @override
  void initState() {
    super.initState();
    // Initialize Services
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final dio = Provider.of<AuthService>(context, listen: false).dio;
       _shiftService = ShiftService(dio);
       _fetchShifts();
    });
  }

  Future<void> _fetchShifts() async {
    setState(() => _isLoadingShifts = true);
    try {
      final data = await _shiftService.getShifts();
      if (mounted) setState(() => _shifts = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading shifts: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingShifts = false);
    }
  }

  Future<void> _deleteShift(int id) async {
     try {
       await _shiftService.deleteShift(id);
       if (mounted) {
         _fetchShifts();
         await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => GlassSuccessDialog(
              title: "Shift Deleted",
              message: "The shift has been successfully deleted.",
              onDismiss: () => Navigator.pop(context),
            ),
         );
       }
     } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
     }
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (ctx) => GlassConfirmationDialog(
        title: "Delete Shift?",
        content: "Are you sure you want to delete this shift? This action cannot be undone.",
        confirmLabel: "Delete",
        confirmColor: Colors.red,
        onConfirm: () {
          Navigator.pop(ctx);
          _deleteShift(id);
        },
      ),
    );
  }

  void _openShiftDialog({Shift? shift}) {
    showDialog(
      context: context,
      builder: (ctx) => AddShiftDialog(
        existingShift: shift,
        onSubmit: (newShift) async {
           try {
             if (shift?.id != null) {
               await _shiftService.updateShift(shift!.id!, newShift);
             } else {
               await _shiftService.createShift(newShift);
             }
             if (mounted) {
                if (ctx.mounted) Navigator.pop(ctx); // Close Form
                _fetchShifts(); // Refresh Grid
                
                // Show Success Dialog
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => GlassSuccessDialog(
                    title: shift?.id != null ? "Shift Updated" : "Shift Created",
                    message: shift?.id != null 
                        ? "The shift details have been successfully updated." 
                        : "New shift has been successfully created.",
                    onDismiss: () => Navigator.pop(context),
                  ),
                );
             }
           } catch(e) {
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
           }
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingShifts) return const Center(child: CircularProgressIndicator()); 

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          _buildHelperHeader(context),
          const SizedBox(height: 24),

          // Shifts Grid
          Expanded(
            child: _shifts.isEmpty 
              ? Center(child: Text("No shifts found", style: GoogleFonts.poppins(color: Colors.grey)))
              : LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we should stack vertically or horizontally
                final isPortrait = constraints.maxWidth < 900; 

                // We'll wrap in Wrap or Grid or ListView depending on layout.
                // Reusing _buildShiftCard for each item.
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.start,
                    children: _shifts.map<Widget>((shift) {
                       final itemWidth = isPortrait ? constraints.maxWidth : (constraints.maxWidth - 48) / 3;
                       
                       return SizedBox(
                         width: itemWidth,
                         child: _buildShiftCard(
                            context,
                            shift: shift,
                         ),
                       );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperHeader(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Shifts',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage work timings and grace periods',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
               _openShiftDialog();
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Add Shift',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, {required Shift shift}) {
    final color = Colors.indigoAccent;
    final icon = Icons.access_time_filled;
    
    // Display shift data
    final title = shift.name;
    final type = "Shift"; 
    final timing = "${shift.startTime} - ${shift.endTime}";
    final gracePeriod = "${shift.gracePeriodMins} Mins";
    final overtime = shift.isOvertimeEnabled ? "On (> ${shift.overtimeThresholdHours}h)" : "Off";
    
    return GestureDetector(
      onLongPress: () => _showShiftOptions(shift),
      onTap: () => _viewShiftDetails(shift),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // No IconButtons here anymore
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: Colors.white10),
            const SizedBox(height: 16),

            // Details List
            _buildDetailRow(context, 'Timing', timing, isBold: true),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Grace Period', gracePeriod, icon: Icons.warning_amber_rounded, iconColor: Colors.amber),
            const SizedBox(height: 12),
            _buildDetailRow(context, 'Overtime', overtime, icon: Icons.bolt, iconColor: const Color(0xFF5B60F6)),
          ],
        ),
      ),
    );
  }

  void _viewShiftDetails(Shift shift) {
    showDialog(
      context: context,
      builder: (ctx) => ShiftDetailDialog(shift: shift),
    );
  }

  void _showShiftOptions(Shift shift) {
    ShiftActionSheet.show(
      context,
      shiftName: shift.name,
      onEdit: () {
         _openShiftDialog(shift: shift);
      },
      onDelete: () {
         if (shift.id != null) _showDeleteConfirm(shift.id!);
      },
    );
  }


  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isBold = false, IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
           mainAxisSize: MainAxisSize.min,
           children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: icon != null ? iconColor : Colors.grey,
                fontWeight: icon != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
           ],
        ),
        const SizedBox(width: 16), // Minimum gap
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold || icon != null ? FontWeight.w600 : FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
