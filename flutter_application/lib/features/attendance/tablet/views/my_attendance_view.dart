
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../models/attendance_record.dart';

class MyAttendanceView extends StatefulWidget {
  const MyAttendanceView({super.key});

  @override
  State<MyAttendanceView> createState() => _MyAttendanceViewState();
}

class _MyAttendanceViewState extends State<MyAttendanceView> {
  // Toggle basic states for visual feedback
  bool _isCheckedIn = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Actions (Stacked Time In / Time Out)
          _buildActionButtons(context),
          
          const SizedBox(height: 32),

          // 2. Date Selector
          _buildDateSelector(context),

          const SizedBox(height: 16),

          // 3. Attendance History List
          Expanded(
            child: _buildHistoryList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Stacked vertically as requested using Glass Cards
    return Column(
      children: [
        // Time In Button
        _buildLargeActionButton(
          context,
          label: 'Time In',
          subLabel: _isCheckedIn ? 'Checked in at 09:30 AM' : 'Start your shift',
          icon: Icons.login,
          color: const Color(0xFF10B981), // Green
          isActive: !_isCheckedIn, // Example logic: disable if already checked in? Or just show state
          onTap: () {
            setState(() => _isCheckedIn = true);
          },
        ),
        const SizedBox(height: 16),
        // Time Out Button
        _buildLargeActionButton(
          context,
          label: 'Time Out',
          subLabel: _isCheckedIn ? 'End current shift' : 'Not checked in',
          icon: Icons.logout,
          color: const Color(0xFFEF4444), // Red
          isActive: _isCheckedIn,
          onTap: () {
            setState(() => _isCheckedIn = false);
          },
        ),
      ],
    );
  }

  Widget _buildLargeActionButton(BuildContext context, {
    required String label,
    required String subLabel,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        height: 100,
        width: double.infinity,
        borderRadius: 20,
        // We can override color to give it a slight tint of the action color if active
        // But let's stick to consistent glass style and use the icon/text for color
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isActive ? color.withOpacity(0.2) : (isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isActive ? color : (isDark ? Colors.grey : Colors.grey),
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    subLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isActive)
                Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Text(
          'Todays Activity',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const Spacer(),
        GlassContainer(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {},
                child: Icon(Icons.chevron_left, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Wed, 02 Jan 2026',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                child: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    // Dummy Data for Multiple Sessions in a Day
    final sessions = [
      {
        'session': 'Session 1',
        'inTime': '09:30 AM',
        'inLocation': 'Reception Area',
        'inImage': Colors.blue.shade100, // Placeholder color for image
        'outTime': '01:00 PM',
        'outLocation': 'Main Exit',
        'outImage': Colors.blue.shade200,
        'duration': '3h 30m',
        'status': 'Completed',
        'color': Colors.green,
      },
      {
        'session': 'Session 2',
        'inTime': '02:00 PM',
        'inLocation': 'Side Entrance',
        'inImage': Colors.orange.shade100,
        'outTime': '06:30 PM',
        'outLocation': 'Main Exit',
        'outImage': Colors.orange.shade200,
        'duration': '4h 30m',
        'status': 'Completed',
        'color': Colors.green,
      },
      {
        'session': 'Session 3',
        'inTime': '08:00 PM',
        'inLocation': 'Remote Login',
        'inImage': Colors.purple.shade100,
        'outTime': null, // Active
        'outLocation': null,
        'outImage': null,
        'duration': 'Running',
        'status': 'Active',
        'color': Colors.blue,
      },
    ];

    return ListView.separated(
      itemCount: sessions.length,
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildSessionCard(context, sessions[index]);
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, Map<String, dynamic> session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = session['color'] as Color;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Session Indicator Strip
            Container(
              width: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history, size: 18, color: statusColor),
                   const SizedBox(height: 4),
                   RotatedBox(
                     quarterTurns: 3,
                     child: Text(
                       '${session['status']}', // "Completed"
                       style: GoogleFonts.poppins(
                         fontSize: 10,
                         fontWeight: FontWeight.w600,
                         color: statusColor,
                         letterSpacing: 0.5,
                       ),
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // In & Out Columns
            Expanded(
              child: Row(
                children: [
                   // IN PUNCH
                   Expanded(
                     child: _buildPunchBlock(
                       context, 
                       type: 'TIME IN', 
                       time: session['inTime'], 
                       location: session['inLocation'], 
                       imageColor: session['inImage'],
                       icon: Icons.login,
                       accentColor: const Color(0xFF10B981),
                     ),
                   ),
                   
                   // Divider / Connector
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 12),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(Icons.arrow_forward, size: 16, color: Colors.grey.withOpacity(0.5)),
                         const SizedBox(height: 4),
                         Text(
                           session['duration'],
                           style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                         )
                       ],
                     ),
                   ),
      
                   // OUT PUNCH
                   Expanded(
                     child: session['outTime'] != null 
                       ? _buildPunchBlock(
                           context, 
                           type: 'TIME OUT', 
                           time: session['outTime'], 
                           location: session['outLocation'], 
                           imageColor: session['outImage'],
                           icon: Icons.logout,
                           accentColor: const Color(0xFFEF4444),
                         )
                       : _buildActivePlaceholder(context),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunchBlock(BuildContext context, {
    required String type,
    required String time,
    required String location,
    required Color? imageColor,
    required IconData icon,
    required Color accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Icon(icon, size: 12, color: accentColor),
              ),
              const SizedBox(width: 6),
              Text(
                type,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: accentColor, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
               // Avatar / Photo Placeholder
               Container(
                 width: 36,
                 height: 36,
                 decoration: BoxDecoration(
                   color: imageColor ?? Colors.grey[300],
                   shape: BoxShape.circle,
                   border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                 ),
                 child: Icon(Icons.person, size: 20, color: Colors.white.withOpacity(0.8)),
               ),
               const SizedBox(width: 10),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     time,
                     style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                   ),
                   Row(
                     children: [
                       Icon(Icons.place, size: 10, color: Colors.grey),
                       const SizedBox(width: 2),
                       SizedBox(
                         width: 60, // Constrain width
                         child: Text(
                           location,
                           style: GoogleFonts.poppins(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                           overflow: TextOverflow.ellipsis,
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlaceholder(BuildContext context) {
     return DottedBorderContainer(
       child: Center(
         child: Text(
           'On Shift',
           style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
         ),
       ),
     );
  }
}

class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  const DottedBorderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.none), // Placeholder for dotted
      ),
      // Using a standard container with dashed border simulation if needed, or simple grey border
      child: Container(
         decoration: BoxDecoration(
           border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1), // Solid for now, simpler
           borderRadius: BorderRadius.circular(12),
         ),
         child: child,
      ),
    );
  }
}

