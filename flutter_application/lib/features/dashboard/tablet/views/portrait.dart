import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../dashboard.dart';
import '../widgets/action_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/anomalies_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/trends_chart.dart';

class TabletPortrait extends StatelessWidget {
  const TabletPortrait({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF334155)]
              : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Sidebar is hidden by default, accessible via Drawer
        drawer: const Drawer(
          width: 250,
          backgroundColor: Colors.transparent, // Drawer transparent for sidebar's glass
          child: AppSidebar(), // Reusing the same sidebar
        ),
        appBar: const CustomAppBar(
          showDrawerButton: true, // Enable menu button
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: KPI Cards (Stacked Grid - 2 Column)
              _buildKPISection(),
              const SizedBox(height: 24),

              // Section 2: Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Section 3: Trends Chart (Full Width)
              const SizedBox(
                height: 400,
                child: TrendsChart(),
              ),
              const SizedBox(height: 24),

               // Section 4: Live Activity Feed (Full Width)
              ActivityFeed(
                activities: DashboardLogic.recentActivity,
              ),
              const SizedBox(height: 24),

              // Section 5: Anomalies (Full Width)
              AnomaliesCard(
                anomalies: DashboardLogic.anomalies,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPISection() {
    // 2 columns for portrait tablet feels right for "cards below each other" 
    // without being excessively tall like a 1-column list.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cards per row
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8, // Slightly wider aspect ratio
      ),
      itemCount: DashboardLogic.kpiData.length,
      itemBuilder: (context, index) {
        final data = DashboardLogic.kpiData[index];
        return StatCard(
          title: data['title'],
          value: data['value'],
          total: data['total'],
          percentage: data['percentage'],
          contextText: data['context'],
          isPositive: data['isPositive'],
          icon: data['icon'],
          baseColor: data['color'],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        // Stacking quick actions vertically as requested "below the other" 
        // or doing a 1-column list? 
        // Let's do a columnar list for "below the other" emphasis in portrait.
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DashboardLogic.quickActions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final data = DashboardLogic.quickActions[index];
            return ActionCard(
              title: data['title'],
              subtitle: data['subtitle'],
              icon: data['icon'],
              color: data['color'],
            );
          },
        ),
        // Alternative: If quick actions should be a grid, I'd use GridView. 
        // But "cards below the other" suggests vertical stacking.
      ],
    );
  }
}
