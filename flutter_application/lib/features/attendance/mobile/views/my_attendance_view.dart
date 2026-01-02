import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class MobileMyAttendanceContent extends StatefulWidget {
  const MobileMyAttendanceContent({super.key});

  @override
  State<MobileMyAttendanceContent> createState() => _MobileMyAttendanceContentState();
}

class _MobileMyAttendanceContentState extends State<MobileMyAttendanceContent> {
  bool _isCheckedIn = true;

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final sessions = [
      {
        'session': 'Session 1',
        'inTime': '09:30 AM',
        'inLocation': 'Reception Area',
        'inImage': Colors.blue.shade100, 
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
        'outTime': null, 
        'outLocation': null,
        'outImage': null,
        'duration': 'Running',
        'status': 'Active',
        'color': Colors.blue,
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. Top Actions (Stacked Time In / Time Out)
        _buildActionButtons(context),
        
        const SizedBox(height: 32),

        // 2. Date Selector
        _buildDateSelector(context),

        const SizedBox(height: 16),

        // 3. Attendance History List
        ...sessions.map((session) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSessionCard(context, session),
        )),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Time In Button
        _buildLargeActionButton(
          context,
          label: 'Time In',
          subLabel: _isCheckedIn ? 'Checked in at 09:30 AM' : 'Start your shift',
          icon: Icons.login,
          color: const Color(0xFF10B981), // Green
          isActive: !_isCheckedIn, 
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Todays Activity',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
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
                      'Wed, 02 Jan',
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



  Widget _buildSessionCard(BuildContext context, Map<String, dynamic> session) {
    // Basic coloring
    const greenColor = Color(0xFF10B981);
    const redColor = Color(0xFFEF4444);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Timeline Column
            Column(
              children: [
                // Start Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: greenColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Line
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.withOpacity(0.3),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
                // End Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: session['outTime'] != null ? redColor : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // 2. Info Column (Time & Address)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // IN Info
                  _buildTimeInfo(
                    context, 
                    time: session['inTime'], 
                    location: session['inLocation'] ?? 'Unknown Location'
                  ),
                  
                  const SizedBox(height: 24), // Spacing between In and Out

                  // OUT Info
                  session['outTime'] != null 
                    ? _buildTimeInfo(
                        context, 
                        time: session['outTime'], 
                        location: session['outLocation'] ?? 'Unknown Location'
                      )
                    : Text(
                        'Currently Active',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. Images Column
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAvatar(session['inImage']),
                if (session['outTime'] != null)
                  _buildAvatar(session['outImage']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(BuildContext context, {required String time, required String location}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildAvatar(Color? colorPlaceholder) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorPlaceholder ?? Colors.grey[300],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Icon(Icons.person, size: 24, color: Colors.white.withOpacity(0.9)),
    );
  }
}

