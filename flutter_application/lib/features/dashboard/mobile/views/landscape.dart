import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard_controller.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/chart_section.dart';
import '../../widgets/activity_list.dart';

import '../../../../shared/widgets/app_sidebar.dart';

class MobileLandscape extends StatelessWidget {
  const MobileLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    // Split View: Left (Sidebar), Center (Stats + Actions), Right (Chart + Feed)
    // Sidebar is fixed 280.
    final controller = context.watch<DashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSidebar(),
            // Existing content split
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.35, 
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: controller.stats.map((stat) => StatCard(stat: stat)).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('QUICK ACTIONS', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 12),
                    Column(
                       children: controller.quickActions.map((action) => Padding(
                         padding: const EdgeInsets.only(bottom: 12),
                         child: QuickActionCard(
                            title: action['title'],
                            subtitle: action['subtitle'],
                            icon: action['icon'],
                            iconColor: action['color'],
                            iconBgColor: action['color'],
                            onTap: action['onTap'],
                          ),
                       )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Right Column
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const ChartSection(),
                    const SizedBox(height: 20),
                     Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(child: LiveActivityCard(activities: controller.activities)),
                         const SizedBox(width: 12),
                         Expanded(child: AnomaliesCard(anomalies: controller.anomalies)),
                       ],
                     ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
