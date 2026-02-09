import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../models/shift_model.dart';
import '../../services/shift_service.dart';
import 'add_shift_dialog.dart';
import 'shift_detail_dialog.dart';
import '../../../../shared/widgets/glass_confirmation_dialog.dart';
import '../../../../shared/widgets/glass_success_dialog.dart';

class PolicyEngineView extends StatefulWidget {
  const PolicyEngineView({super.key});

  @override
  State<PolicyEngineView> createState() => _PolicyEngineViewState();
}

class _PolicyEngineViewState extends State<PolicyEngineView> {
  late ShiftService _shiftService;

  List<Shift> _shifts = [];
  bool _isLoadingShifts = true;

  // Selection Mode State
  Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

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
         if (!_isSelectionMode) {
           showDialog(
             context: context,
             builder: (context) => GlassSuccessDialog(
               title: "Shift Deleted",
               message: "The shift has been successfully deleted.",
               onDismiss: () => Navigator.pop(context),
             ),
           );
         }
       }
     } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
     }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _shifts.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds = _shifts.where((s) => s.id != null).map((s) => s.id!).toSet();
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => GlassConfirmationDialog(
        title: 'Confirm Bulk Delete',
        content: 'Are you sure you want to delete ${_selectedIds.length} shifts?',
        confirmLabel: 'Delete',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      // Loop delete since API doesn't support bulk yet
      for (final id in _selectedIds) {
        await _shiftService.deleteShift(id);
      }
      
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context); // Close loading

      _exitSelectionMode();
      _fetchShifts();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected shifts deleted')));
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete some shifts: $e')));
    }
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
             constraints: const BoxConstraints(maxWidth: 400),
             child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Delete Shift?",
                        style: GoogleFonts.poppins(
                           fontSize: 18,
                           fontWeight: FontWeight.w600,
                           color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Are you sure you want to delete this shift? This action cannot be undone.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                           fontSize: 14,
                           color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                "Cancel",
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
                              onPressed: () {
                                Navigator.pop(ctx);
                                _deleteShift(id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              child: Text(
                                "Delete",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
    );
  }

  void _openShiftDialog({Shift? shift}) {
    showDialog(
      context: context,
      builder: (ctx) => AddShiftDialog(
        existingShift: shift,
        onSubmit: (newShift) async {
           try {
             final isUpdate = shift?.id != null;
             if (isUpdate) {
               await _shiftService.updateShift(shift!.id!, newShift);
             } else {
               await _shiftService.createShift(newShift);
             }
             if (mounted) {
                Navigator.pop(ctx);
                _fetchShifts();
                showDialog(
                  context: context,
                  builder: (context) => GlassSuccessDialog(
                    title: isUpdate ? "Shift Updated" : "Shift Created",
                    message: isUpdate 
                      ? "The shift has been successfully updated."
                      : "The shift has been successfully created.",
                    onDismiss: () => Navigator.pop(context),
                  ),
                );
             }
           } catch(e) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
           }
        },
      )
    );
  }


  void _showShiftDetails(Shift shift) {
    showDialog(
      context: context,
      builder: (context) => ShiftDetailDialog(shift: shift),
    );
  }

  void _showActionSheet(Shift shift) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
             color: isDark ? const Color(0xFF1E2939) : Colors.white,
             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, 
                height: 4, 
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300], 
                  borderRadius: BorderRadius.circular(2)
                ),
              ),
              _buildActionItem(
                context, 
                icon: Icons.edit_outlined, 
                label: 'Edit Shift', 
                onTap: () {
                  Navigator.pop(context);
                  _openShiftDialog(shift: shift);
                }
              ),
              const SizedBox(height: 8),
              _buildActionItem(
                context, 
                icon: Icons.delete_outline, 
                label: 'Delete Shift', 
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  if (shift.id != null) _showDeleteConfirm(shift.id!);
                }
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActionItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? (isDark ? Colors.white : Colors.black87), size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16, 
                fontWeight: FontWeight.w500,
                color: color ?? (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingShifts) return const Center(child: CircularProgressIndicator()); 

    // Responsive padding: minimal for mobile, standard for tablet/desktop
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final horizontalPadding = isMobile ? 8.0 : 32.0;
    final verticalPadding = isMobile ? 12.0 : 24.0;
    final bottomPadding = isMobile ? 8.0 : 32.0;
    final headerSpacing = isMobile ? 12.0 : 24.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, bottomPadding),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          _buildHelperHeader(context),
          SizedBox(height: headerSpacing),

          // Shifts Grid
          if (_shifts.isEmpty)
            SizedBox(
              height: 300,
              child: Center(child: Text("No shifts found", style: GoogleFonts.poppins(color: Colors.grey))),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                // Determine if we should stack vertically or horizontally
                final isPortrait = constraints.maxWidth < 900; 

                // We'll wrap in Wrap or Grid or ListView depending on layout.
                // Reusing _buildShiftCard for each item.
                return Wrap(
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
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHelperHeader(BuildContext context) {
    if (_isSelectionMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitSelectionMode,
            ),
            const SizedBox(width: 8),
            Text('${_selectedIds.length} Selected', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            TextButton(
              onPressed: _toggleSelectAll,
              child: Text(
                _selectedIds.length == _shifts.length ? 'Unselect All' : 'Select All',
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _bulkDelete,
            ),
          ],
        ),
      );
    }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Selection Logic
    final isSelected = shift.id != null && _selectedIds.contains(shift.id);

    // Calculate duration (simple approximation if needed, or pass from backend)
    // Display shift data
    final title = shift.name;
    final type = "Shift"; 
    final timing = "${shift.startTime} - ${shift.endTime}";
    final gracePeriod = "${shift.gracePeriodMins} Mins";
    final overtime = shift.isOvertimeEnabled ? "On (> ${shift.overtimeThresholdHours}h)" : "Off";
    
    
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode && shift.id != null) {
          _toggleSelection(shift.id!);
        } else {
          _showShiftDetails(shift);
        }
      },
      onLongPress: () => _showActionSheet(shift), // Updated to show Sheet
      child: Stack(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(24),
            border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
            gradient: isSelected 
                ? LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      Theme.of(context).primaryColor.withValues(alpha: 0.05)
                    ],
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
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
                    if (!_isSelectionMode) // Hide menu in selection mode
                      IconButton(
                        onPressed: () => _showActionSheet(shift),
                        icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.grey),
                      ),
                    if (_isSelectionMode)
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) {
                          if (shift.id != null) _toggleSelection(shift.id!);
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
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
          if (isSelected)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
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
              Icon(icon, size: 14, color: iconColor ?? Colors.grey),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey,
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
