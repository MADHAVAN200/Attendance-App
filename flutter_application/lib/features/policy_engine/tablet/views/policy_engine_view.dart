import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/auth_service.dart';
import '../../models/shift_model.dart';
import '../../services/shift_service.dart';
import 'add_shift_dialog.dart';

class PolicyEngineView extends StatefulWidget {
  const PolicyEngineView({super.key});

  static final ValueNotifier<int> initialTabNotifier = ValueNotifier<int>(0);

  @override
  State<PolicyEngineView> createState() => _PolicyEngineViewState();
}

class _PolicyEngineViewState extends State<PolicyEngineView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ShiftService _shiftService;
  List<Shift> _shifts = [];
  bool _isLoadingShifts = true;

  @override
  void initState() {
    super.initState();
    final initialIndex = PolicyEngineView.initialTabNotifier.value;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    
    if (initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PolicyEngineView.initialTabNotifier.value = 0;
      });
    }

    // Initialize Service
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
               await _shiftService.updateShift(shift!.id!, newShift);
             } else {
               await _shiftService.createShift(newShift);
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        _buildTabs(context),


        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAutomationRules(context),
              _buildShiftConfiguration(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final margin = isMobile ? 16.0 : 32.0;

        return Container(
          margin: EdgeInsets.fromLTRB(margin, 24, margin, 24),
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false, // Ensure tabs fill width
            tabAlignment: TabAlignment.fill,
            indicator: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isDark ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ] : [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Colors.grey[500] : Colors.grey[600],
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'Automation Rules'),
              Tab(text: 'Shift Configuration'),
            ],
          ),
        );
      }
    );
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

  Widget _buildShiftConfiguration(BuildContext context) {
    if (_isLoadingShifts) return const Center(child: CircularProgressIndicator()); 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
              backgroundColor: const Color(0xFF5B60F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Colors.indigoAccent;
    final icon = Icons.access_time_filled;
    
    // Calculate duration (simple approximation if needed, or pass from backend)
    // Display shift data
    final title = shift.name;
    final type = "Shift"; // Backend doesn't seem to have type yet, or maybe 'shift_name' implies it?
    final timing = "${shift.startTime} - ${shift.endTime}";
    final gracePeriod = "${shift.gracePeriodMins} Mins";
    final overtime = shift.isOvertimeEnabled ? "On (> ${shift.overtimeThresholdHours}h)" : "Off";
    
    
    return GlassContainer(
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
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: Colors.white10),
          const SizedBox(height: 16),

          // Details List
          _buildDetailRow(context, 'Timing', timing, isBold: true),
          const SizedBox(height: 12),
          // _buildDetailRow(context, 'Duration', duration), // Duration omitted for simplicity or calculated
          // const SizedBox(height: 16),
          // const Divider(height: 1, thickness: 1, color: Colors.white10),
          // const SizedBox(height: 16),
          _buildDetailRow(context, 'Grace Period', gracePeriod, icon: Icons.warning_amber_rounded, iconColor: Colors.amber),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Overtime', overtime, icon: Icons.bolt, iconColor: const Color(0xFF5B60F6)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isBold = false, IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
