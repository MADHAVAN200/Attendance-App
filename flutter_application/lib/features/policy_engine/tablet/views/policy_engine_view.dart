import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../services/auth_service.dart';
import '../../../../shared/models/shift_model.dart';
import '../../../../services/policy_service.dart';
import 'add_shift_dialog.dart';

class PolicyEngineView extends StatefulWidget {
  const PolicyEngineView({super.key});

  static final ValueNotifier<int> initialTabNotifier = ValueNotifier<int>(0);

  @override
  State<PolicyEngineView> createState() => _PolicyEngineViewState();
}

class _PolicyEngineViewState extends State<PolicyEngineView> {

  late PolicyService _policyService;
  List<Shift> _shifts = [];
  bool _isLoadingShifts = true;

  @override
  void initState() {
    super.initState();

    // Initialize Service
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _policyService = PolicyService();
       _fetchShifts();
    });
  }

  Future<void> _fetchShifts() async {
    setState(() => _isLoadingShifts = true);
    try {
      final data = await _policyService.getAllShifts();
      if (mounted) setState(() => _shifts = data);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading shifts: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingShifts = false);
    }
  }

  Future<void> _deleteShift(int id) async {
     try {
       await _policyService.deleteShift(id);
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shift deleted")));
         _fetchShifts();
       }
     } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
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
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 32),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        "Delete Shift?",
                        style: GoogleFonts.poppins(
                           fontSize: 18,
                           fontWeight: FontWeight.w600,
                           color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Message
                      Text(
                        "Are you sure you want to delete this shift? This action cannot be undone.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                           fontSize: 14,
                           color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
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
             if (shift?.id != null) {
               await _policyService.updateShift(shift!.id!, newShift.toJson());
             } else {
               await _policyService.createShift(newShift.toJson());
             }
             if (mounted) {
                Navigator.pop(ctx);
                _fetchShifts();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shift Saved")));
             }
           } catch(e) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
           }
        },
      )
    );
  }

  void _showShiftPreview(Shift shift) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = Theme.of(context).textTheme.bodyLarge?.color;
        final subTextColor = Colors.grey;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shift.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "Shift Details",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close, color: subTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 24),

                    // Section 1: Timing
                    Text("TIMING & SCHEDULE", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: subTextColor, letterSpacing: 1)),
                    const SizedBox(height: 16),
                    _buildPreviewRow(context, "Shift Time", "${shift.startTime} - ${shift.endTime}"),
                    _buildPreviewRow(context, "Grace Period", "${shift.gracePeriodMins} Minutes"),
                    _buildPreviewRow(context, "Overtime", shift.isOvertimeEnabled ? "Enabled (> ${shift.overtimeThresholdHours}h)" : "Disabled"),
                    const SizedBox(height: 16),
                     Text("Working Days", style: GoogleFonts.poppins(fontSize: 13, color: subTextColor)),
                     const SizedBox(height: 8),
                     if (shift.workingDays.isEmpty)
                       Text("No working days set", style: GoogleFonts.poppins(fontSize: 13, color: textColor, fontStyle: FontStyle.italic))
                     else
                       Wrap(
                         spacing: 8,
                         runSpacing: 8,
                         children: shift.workingDays.map((day) => Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: isDark ? Colors.white12 : Colors.grey[200],
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                           ),
                           child: Text(
                             day, 
                             style: GoogleFonts.poppins(
                               fontSize: 12, 
                               fontWeight: FontWeight.w500,
                               color: isDark ? Colors.white : Colors.black87
                             )
                           ),
                         )).toList(),
                       ),
                    const SizedBox(height: 16),
                    if (shift.alternateSaturdays.enabled) ...[
                       Text("Alternate Saturdays Off", style: GoogleFonts.poppins(fontSize: 13, color: subTextColor)),
                       const SizedBox(height: 8),
                       Text(
                         "Week ${shift.alternateSaturdays.off.join(', ')}",
                         style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
                       ),
                    ],

                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 24),

                    // Section 2: Requirements
                    Text("REQUIREMENTS", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: subTextColor, letterSpacing: 1)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildRequirementCard(context, "Entry", shift.policyRules.entryRequirements.selfie, shift.policyRules.entryRequirements.geofence)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRequirementCard(context, "Exit", shift.policyRules.exitRequirements.selfie, shift.policyRules.exitRequirements.geofence)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B60F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Close", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildPreviewRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(BuildContext context, String title, bool selfie, bool geofence) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 8),
          _buildReqItem(context, Icons.camera_alt_outlined, "Selfie", selfie),
          const SizedBox(height: 4),
          _buildReqItem(context, Icons.location_on_outlined, "Geofence", geofence),
        ],
      ),
    );
  }

  Widget _buildReqItem(BuildContext context, IconData icon, String label, bool enabled) {
    return Row(
      children: [
        Icon(icon, size: 14, color: enabled ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text(
          label, 
          style: GoogleFonts.poppins(
            fontSize: 12, 
            color: enabled ? (Theme.of(context).textTheme.bodyLarge?.color) : Colors.grey,
            decoration: enabled ? null : TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }



  // ... (Keeping _buildAutomationRules as is, focusing on _buildTabs change above) ...
  // Wait, I need to output _buildDetailRow as well.
  // The tool asks for CONTIGUOUS block.
  // _buildTabs is lines 223-275.
  // _buildDetailRow is lines 887-914.
  // These are far apart. I must use multi_replace or two replace calls.
  // I will use multi_replace_file_content since search/replace is better for separate blocks.
  // Wait, I'll just use two replace calls to be safe and simple.
  // This first call targets `_buildTabs`.


  Widget _buildAutomationRules(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxWidth < 900;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (isPortrait) {
          return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.screen_rotation, size: 64, color: Colors.grey[400]),
                 const SizedBox(height: 24),
                 Text(
                   'Please rotate your device',
                   style: GoogleFonts.poppins(
                     fontSize: 20,
                     fontWeight: FontWeight.w600,
                     color: isDark ? Colors.white : Colors.black87,
                   ),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   'Automation Rules are only available in landscape mode',
                   style: GoogleFonts.poppins(
                     fontSize: 14,
                     color: Colors.grey[500],
                   ),
                   textAlign: TextAlign.center,
                 ),
               ],
             ),
           );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Left: Toolbox
              Expanded(
                flex: 2,
                child: _buildToolbox(context),
              ),
              const SizedBox(width: 24),

              // 2. Center: Canvas
              Expanded(
                flex: 5,
                child: _buildCanvas(context),
              ),
              const SizedBox(width: 24),

              // 3. Right: Properties Panel
              Expanded(
                flex: 3,
                child: _buildPropertiesPanel(context),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildToolbox(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOOLBOX',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildToolboxSection(context, 'CONDITIONS', [
            {'icon': Icons.access_time, 'label': 'Time Check'},
            {'icon': Icons.location_on_outlined, 'label': 'Location Check'},
            {'icon': Icons.calendar_today, 'label': 'Date Range'},
          ]),
          const SizedBox(height: 24),
          _buildToolboxSection(context, 'ACTIONS', [
            {'icon': Icons.notification_important_outlined, 'label': 'Send Alert'},
            {'icon': Icons.check_circle_outline, 'label': 'Auto Approve'},
            {'icon': Icons.cancel_outlined, 'label': 'Reject Request'},
            {'icon': Icons.email_outlined, 'label': 'Email Manager'},
          ]),
        ],
      ),
    );
  }

  Widget _buildToolboxSection(BuildContext context, String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCanvas(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassContainer(
      padding: EdgeInsets.zero,
      color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
      child: Stack(
        children: [
          // Grid Background Pattern (Simplified)
          Opacity(
            opacity: 0.05,
            child: GridPaper(
              color: Theme.of(context).primaryColor,
              divisions: 2,
              subdivisions: 2,
            ),
          ),
          
          // Flow Diagram
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFlowBlock(context, 'TRIGGER', 'Attendance Marked', Icons.touch_app, isActive: false),
                  _buildFlowArrow(context),
                  _buildFlowBlock(context, 'CONDITION', 'Is Late > 15 mins?', Icons.access_time, isActive: true),
                  _buildFlowArrow(context),
                  _buildFlowBlock(context, 'ACTION', 'Send Warning Alert', Icons.notification_important_outlined, isActive: false),
                ],
              ),
            ),
          ),
          
          // Canvas Label
           Positioned(
            top: 20,
            left: 20,
            child: Text(
              'RULE FLOW: LATE ARRIVAL POLICY',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowBlock(BuildContext context, String type, String label, IconData icon, {bool isActive = false}) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive 
            ? (isDark ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1))
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? primaryColor : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive ? [
          BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? primaryColor : Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (isActive)
                Icon(Icons.edit, size: 14, color: primaryColor)
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, size: 20, color: isActive ? primaryColor : Theme.of(context).textTheme.bodyMedium?.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowArrow(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 2,
          height: 20,
          color: Colors.grey.withOpacity(0.5),
        ),
        Icon(Icons.keyboard_arrow_down, color: Colors.grey.withOpacity(0.5)),
        Container(
          width: 2,
          height: 10,
          color: Colors.grey.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildPropertiesPanel(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROPERTIES',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Condition Settings',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildPropertyField(context, 'Label', 'Is Late > 15 mins?'),
          const SizedBox(height: 16),
          _buildPropertyField(context, 'Threshold (mins)', '15'),
          const SizedBox(height: 16),
           _buildPropertyDropdown(context, 'Operator', 'Greater Than'),
           const SizedBox(height: 16),
          _buildPropertyDropdown(context, 'Priority', 'High'),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Update Block',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyField(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
               color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

   Widget _buildPropertyDropdown(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_drop_down, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildFAB(BuildContext context, bool isMobile) {
    if (!isMobile) return null;
    
    return FloatingActionButton(
      onPressed: () => _openShiftDialog(),
      backgroundColor: const Color(0xFF5B60F6),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    // -------------------------------------------------------------------------
    // 1. Theme & Layout Logic
    // -------------------------------------------------------------------------
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    // UPDATED COLORS
    final backgroundColor = isDark ? Colors.transparent : const Color(0xFFF8FAFC);


    return Scaffold(
      backgroundColor: backgroundColor,
      body: _buildShiftConfiguration(context, isMobile),
      floatingActionButton: _buildFAB(context, isMobile),
    );
  }

  Widget _buildShiftConfiguration(BuildContext context, bool isMobile) {
    // if (_isLoadingShifts) return const Center(child: CircularProgressIndicator()); 

    return LayoutBuilder(
      builder: (context, constraints) {
        // final isMobile = constraints.maxWidth < 600; // Now passed in
        // final padding = isMobile ? 16.0 : 32.0; // Now calculated below

        // ---------------------------------------------------------------------
        // 2. Dynamic Sizing
        // ---------------------------------------------------------------------
        // Adjust padding based on screen width
        double padding = isMobile ? 16 : 32;
        if (constraints.maxWidth > 1200) padding = 64; // Extra padding for large screens

        // Grid Layout logic
        int crossAxisCount = 3;
        if (constraints.maxWidth < 800) crossAxisCount = 1;
        else if (constraints.maxWidth < 1100) crossAxisCount = 2;

        // Calculate helper width (100% or slightly less on massive screens)
        // Helper stays full width of the content area
        
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 10, padding, padding), // Top padding 10
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Extra top padding for mobile to separate from AppBar
              // SizedBox(height: isMobile ? 16 : 12), // Replaced by top padding in SingleChildScrollView
            
              // Header Section
              _buildHelperHeader(context, isMobile),
              const SizedBox(height: 10), // Reduced spacing

              // Shifts Grid (No Expanded needed since parent is scrollable)
              if (_isLoadingShifts) // Use _isLoadingShifts from original
                 const Center(child: CircularProgressIndicator())
               else if (_shifts.isEmpty)
                 _buildEmptyState(context) // Assuming _buildEmptyState exists or will be added
               else
                 Wrap(
                  spacing: 10, // Reduced spacing
                  runSpacing: 10, // Reduced spacing
                  // alignment: WrapAlignment.start, // Removed from new code
                  children: _shifts.map<Widget>((shift) {
                    // Calculate precise width for cards based on available space and spacing
                    // width = (totalWidth - (spacing * (cols - 1))) / cols
                     double itemWidth = (constraints.maxWidth - (padding * 2));
                     if (crossAxisCount > 1) {
                        itemWidth = (constraints.maxWidth - (padding * 2) - (10 * (crossAxisCount - 1))) / crossAxisCount;
                     }
                       
                       return SizedBox(
                         width: itemWidth,
                         child: _buildShiftCard(
                            context,
                            shift: shift,
                            isMobile: isMobile,
                         ),
                       );
                    }).toList(),
                  ),
               // Bottom padding
               SizedBox(height: padding),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHelperHeader(BuildContext context, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 16 : 20),
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
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage work timings and grace periods',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 13,
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
                fontSize: isMobile ? 13 : 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B60F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 12 : 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(
    BuildContext context, {
    required Shift shift,
    bool isMobile = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Colors.indigoAccent;
    final icon = Icons.access_time_filled;
    
    // Calculate duration
    String duration = "0h 00m";
    try {
      final start = _parseTime(shift.startTime);
      final end = _parseTime(shift.endTime);
      int minutes = end.difference(start).inMinutes;
      if (minutes < 0) minutes += 24 * 60; // Handle overnight
      final h = minutes ~/ 60;
      final m = minutes % 60;
      duration = "${h}h ${m.toString().padLeft(2, '0')}m";
    } catch (e) {
      // Keep default
    }

    final timing = "${shift.startTime} - ${shift.endTime}";
    final gracePeriod = "${shift.gracePeriodMins} mins";
    
    return GestureDetector(
      onTap: () => _showShiftPreview(shift),
      child: GlassContainer(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  shift.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _openShiftDialog(shift: shift), 
                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey)
              ),
              IconButton(
                onPressed: () {
                   if (shift.id != null) _showDeleteConfirm(shift.id!);
                }, 
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey)
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          const SizedBox(height: 16),

          // Section 1: Timing & Duration (No Icons)
          _buildDetailRow(context, 'Timing', timing, valueColor: isDark ? Colors.white : Colors.black),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Duration', duration, valueColor: isDark ? Colors.white : Colors.black),
          
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          const SizedBox(height: 16),

          // Section 2: Grace Period & Overtime (With Icons)
          _buildDetailRow(
            context, 
            'Grace Period', 
            gracePeriod, 
            icon: Icons.warning_amber_rounded, 
            iconColor: Colors.orange,
            labelColor: Colors.orange,
            valueColor: isDark ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context, 
            'Overtime', 
            '', // Value handled by custom widget
            icon: Icons.bolt, 
            iconColor: const Color(0xFF5B60F6),
            labelColor: const Color(0xFF5B60F6),
            customValue: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                 shift.isOvertimeEnabled ? "On" : "Off",
                 style: GoogleFonts.poppins(
                   fontSize: 11, 
                   fontWeight: FontWeight.w600,
                   color: isDark ? Colors.white70 : Colors.black54,
                 ),
              ),
            ),
          ),
        ],
      ),
    ),
   );
  }

  // Helper to parse HH:MM
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  Widget _buildDetailRow(
    BuildContext context, 
    String label, 
    String value, 
    {
      bool isBold = false, 
      IconData? icon, 
      Color? iconColor,
      Color? labelColor,
      Color? valueColor,
      Widget? customValue,
    }
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Side: Icon + Label
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                SizedBox(
                  width: 24,
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              ],
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: labelColor ?? (icon != null ? iconColor : Colors.grey),
                    fontWeight: icon != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right Side: Value
        if (customValue != null)
           customValue
        else
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold || icon != null ? FontWeight.w600 : FontWeight.w500,
              color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.end,
          ),
      ],
    );
  }
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No Shifts Found",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
             const SizedBox(height: 8),
             Text(
              "Create a new shift to get started",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
