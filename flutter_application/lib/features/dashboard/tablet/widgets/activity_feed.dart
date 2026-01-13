import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';

class ActivityFeed extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityFeed({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor.withOpacity(0.1);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Activity',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Divider(
              height: 24,
              color: dividerColor,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: activity['color'].withOpacity(0.1),
                    child: Text(
                      activity['avatar'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: activity['color'],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '${activity['role']} • ${activity['action']}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Text(
                      activity['time'],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: activity['status'] == 'late' 
                            ? const Color(0xFFF59E0B) 
                            : (activity['status'] == 'leave' ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.2) : dividerColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'View Full Feed',
                style: GoogleFonts.poppins(
                  fontSize: 12, 
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).primaryColor
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
