import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import 'add_shift_dialog.dart';

class PolicyEngineView extends StatefulWidget {
  const PolicyEngineView({super.key});

  @override
  State<PolicyEngineView> createState() => _PolicyEngineViewState();
}

class _PolicyEngineViewState extends State<PolicyEngineView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        const SizedBox(height: 24),

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

    return Container(
      margin: const EdgeInsets.fromLTRB(32, 32, 32, 0),
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Automation Rules'),
          Tab(text: 'Shift Configuration'),
        ],
      ),
    );
  }

  Widget _buildAutomationRules(BuildContext context) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Header Section
          _buildHelperHeader(context),
          const SizedBox(height: 24),

          // Shifts Grid
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildShiftCard(
                      context,
                      title: 'General Shift',
                      type: 'FIXED',
                      timing: '09:00 - 18:00',
                      duration: '9h 00m',
                      gracePeriod: '15 Mins',
                      overtime: 'On (> 9h)',
                      icon: Icons.access_time_filled,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildShiftCard(
                      context,
                      title: 'Morning Shift',
                      type: 'ROTATIONAL',
                      timing: '06:00 - 14:00',
                      duration: '9h 00m',
                      gracePeriod: '10 Mins',
                      overtime: 'Off',
                      icon: Icons.wb_sunny_outlined,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildShiftCard(
                      context,
                      title: 'Night Shift',
                      type: 'NIGHT',
                      timing: '22:00 - 06:00',
                      duration: '9h 00m',
                      gracePeriod: '30 Mins',
                      overtime: 'On (> 8h)',
                      icon: Icons.nightlight_round,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
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
          Column(
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
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddShiftDialog(),
              );
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
    required String title,
    required String type,
    required String timing,
    required String duration,
    required String gracePeriod,
    required String overtime,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
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
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: Colors.white10),
          const SizedBox(height: 16),

          // Details List
          _buildDetailRow(context, 'Timing', timing, isBold: true),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Duration', duration),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Colors.white10),
          const SizedBox(height: 16),
          _buildDetailRow(context, 'Grace Period', gracePeriod, icon: Icons.warning_amber_rounded, iconColor: Colors.amber),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Overtime', overtime, icon: Icons.bolt, iconColor: const Color(0xFF5B60F6)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isBold = false, IconData? icon, Color? iconColor}) {
    return Row(
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
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isBold || icon != null ? FontWeight.w600 : FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
