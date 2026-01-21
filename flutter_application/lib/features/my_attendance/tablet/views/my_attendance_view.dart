import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';

class MyAttendanceView extends StatelessWidget {
  const MyAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
                child: _buildTimeAction(
                  context, 
                  label: 'Time In', 
                  icon: Icons.login_rounded, 
                  isPrimary: true
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTimeAction(
                  context, 
                  label: 'Time Out', 
                  icon: Icons.logout_rounded, 
                  isPrimary: false
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Date Selector
          _buildDateSelector(context),
          const SizedBox(height: 24),

          // Attendance History List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildHistoryCard(context, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAction(BuildContext context, {
    required String label, 
    required IconData icon, 
    required bool isPrimary
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () {},
      child: Container(
        height: 120, // Large button
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(
             color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!
          ),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: 32, 
                color: isPrimary ? Colors.white : (isDark ? Colors.white : primaryColor)
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : (isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
             Text(
              isPrimary ? 'Start your shift' : 'End your shift',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isPrimary ? Colors.white.withOpacity(0.8) : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassContainer(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.chevron_left)
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.chevron_right)
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.now().subtract(Duration(days: index));
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Date Column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(date),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  DateFormat('EEE').format(date).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Times
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildTimeBlock(context, 'Check In', '09:00 AM', Icons.login, Colors.green),
                const SizedBox(width: 32),
                _buildTimeBlock(context, 'Check Out', '06:00 PM', Icons.logout, Colors.orange),
              ],
            ),
          ),
          
          // Location
          Expanded(
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'Office HQ',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Present',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(BuildContext context, String label, String time, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            Text(
              time,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
