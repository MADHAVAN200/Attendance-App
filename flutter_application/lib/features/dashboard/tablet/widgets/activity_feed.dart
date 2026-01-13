import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/models/dashboard_model.dart';

class ActivityFeed extends StatelessWidget {
  final List<ActivityLog> activities;

  const ActivityFeed({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    
    if (activities.isEmpty) {
      return const GlassContainer(
        padding: EdgeInsets.all(24),
        child: Center(child: Text("No live activity today")),
      );
    }

    final dividerColor = Theme.of(context).dividerColor.withOpacity(0.1);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    // Calculate max height based on approx item height (row + divider) * 5 items
    // Row height ~ 60, Divider = 24. Total per item ~ 84. 5 items ~ 420.
    // Or just use a fixed constraint.
    const double maxFeedHeight = 400.0;

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
          
          // Constrained Scrollable List
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: maxFeedHeight, 
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                height: 24,
                color: dividerColor,
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                final avatarChar = activity.user.isNotEmpty ? activity.user[0] : '?';
                
                final color = Colors.primaries[index % Colors.primaries.length];

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withOpacity(0.1),
                      child: Text(
                        avatarChar,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.user,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '${activity.role} • ${activity.action}',
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
                        activity.time,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
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
                'View All History', // Changed label slightly to indicate history
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
