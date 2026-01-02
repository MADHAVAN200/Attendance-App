import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../tablet/widgets/stat_card.dart';
import '../../tablet/widgets/action_card.dart';
import '../../tablet/widgets/activity_feed.dart';
import '../../tablet/widgets/trends_chart.dart';
import '../../tablet/widgets/anomalies_card.dart';
import '../../dashboard.dart'; // Import for DashboardLogic

class MobileDashboardContent extends StatelessWidget {
  const MobileDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      // Add padding to avoid content being stuck behind the header if necessary, 
      // but usually CustomAppBar is outside the scroll view in our new layout.
      // However, we might want a bit of top spacing for aesthetics.
      slivers: [
        
        // 1. KPI Section (Vertical Stack)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Overview',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildMobileKPIStack(),
              const SizedBox(height: 32),
            ]),
          ),
        ),

        // 2. Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: DashboardLogic.quickActions.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildQuickActionItem(
                        context, 
                        action['title'], 
                        action['icon'], 
                        action['color']
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // 3. Analytics
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Analytics',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Chart
              const SizedBox(
                height: 300,
                child: TrendsChart(),
              ),
              const SizedBox(height: 24),
              // Activity Feed
              ActivityFeed(activities: DashboardLogic.recentActivity), // Usage of DashboardLogic
              const SizedBox(height: 24),
              // Anomalies Card
              AnomaliesCard(anomalies: DashboardLogic.anomalies), // Usage of DashboardLogic
              const SizedBox(height: 40), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileKPIStack() {
    return Column(
      children: DashboardLogic.kpiData.map((data) { // Usage of DashboardLogic
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 125, // Increased height to prevent overflow (was 110)
            child: StatCard(
              title: data['title'],
              value: data['value'],
              total: data['total'],
              percentage: data['percentage'],
              contextText: data['context'],
              isPositive: data['isPositive'],
              icon: data['icon'],
              baseColor: data['color'],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, String title, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
        ],
      ),
    );
  }
}
