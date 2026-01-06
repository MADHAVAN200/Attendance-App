import 'package:flutter/material.dart';
import '../../dashboard.dart';
import '../widgets/action_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/anomalies_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/trends_chart.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          const SizedBox(height: 32),

          // Row 4: Anomalies (Full Width)
          AnomaliesCard(
            anomalies: DashboardLogic.anomalies,
          ),
        ],
      ),
    );
  }

  Widget _buildKPISection() {
    return Row(
      children: DashboardLogic.kpiData.map((data) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // Gutter
             child: SizedBox(
              height: 140, // Fixed height to constrain Expanded child
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
        // Left Column: Chart (Flex 2 - 66%)
         const Expanded(
          flex: 2,
          child: SizedBox(
            height: 400,
            child: TrendsChart(),
          ),
        ),
        const SizedBox(width: 24),
         
        // Right Column: Feed (Flex 1 - 33%)
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 400,
            child: ActivityFeed(
              activities: DashboardLogic.recentActivity,
            ),
          ),
        ),
      ],
    );
  }
}
