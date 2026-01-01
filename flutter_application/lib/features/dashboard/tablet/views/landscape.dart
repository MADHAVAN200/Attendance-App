import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard_controller.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/chart_section.dart';
import '../../widgets/activity_list.dart';

import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class TabletLandscape extends StatelessWidget {
  const TabletLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const CustomAppBar(showDrawerButton: false),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7, // Wider chart
                      child: Column(
                        children: [
                          const ChartSection(),
                          const SizedBox(height: 20),
                          AnomaliesCard(anomalies: controller.anomalies),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3, // Narrower activity feed
                      child: LiveActivityCard(activities: controller.activities),
                    ),
                  ],
                ),
                  ],
                ),
              ),
            ),
            ), // Close Expanded
          ],
        ),
      ),
    );
  }
}
