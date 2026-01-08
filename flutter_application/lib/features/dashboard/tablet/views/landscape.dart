import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../dashboard.dart';
import '../widgets/action_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/anomalies_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/trends_chart.dart';
import '../../../../shared/navigation/navigation_controller.dart';
import '../../../policy_engine/tablet/views/policy_engine_view.dart';

class TabletLandscape extends StatelessWidget {
  const TabletLandscape({super.key});

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
        // Add a subtle pattern or blobs if needed for more "glass" pop.
        // For now, a strong gradient is good.
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // SafeArea isn't strictly needed for tablet landscape usually if sidebar is there, 
        // but let's keep consistent structure.
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const CustomAppBar(showDrawerButton: false),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: KPI Cards
                      _buildKPISection(),
                      const SizedBox(height: 32),

                      // Row 2: Quick Actions
                      _buildQuickActions(),
                      const SizedBox(height: 32),

                      // Row 3: Split View (Chart & Feed)
                      _buildSplitView(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPISection() {
    return Row(
      children: DashboardLogic.kpiData.map((data) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // Gutter
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 2.5,
          ),
          itemCount: DashboardLogic.quickActions.length,
          itemBuilder: (context, index) {
            final data = DashboardLogic.quickActions[index];
            return ActionCard(
              title: data['title'],
              subtitle: data['subtitle'],
              icon: data['icon'],
              color: data['color'],
              onTap: () {
                if (data['page'] != null) {
                  if (data['initialTab'] != null) {
                    PolicyEngineView.initialTabNotifier.value = data['initialTab'] as int;
                  }
                  navigateTo(data['page'] as PageType);
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSplitView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Chart (Flex 7 - 70%)
         const Expanded(
          flex: 7,
          child: SizedBox(
            height: 400,
            child: TrendsChart(),
          ),
        ),
        const SizedBox(width: 24),
         
        // Right Column: Feed & Anomalies (Flex 3 - 30%)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              ActivityFeed(
                activities: DashboardLogic.recentActivity,
              ),
              const SizedBox(height: 24),
               AnomaliesCard(
                anomalies: DashboardLogic.anomalies,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
