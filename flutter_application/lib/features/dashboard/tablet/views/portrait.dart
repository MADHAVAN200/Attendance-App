import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard_controller.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/chart_section.dart';
import '../../widgets/activity_list.dart';

import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class TabletPortrait extends StatelessWidget {
  const TabletPortrait({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();

    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const Drawer(
        width: 280,
        child: AppSidebar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
               GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.4, 
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: controller.stats.map((stat) => StatCard(stat: stat)).toList(),
              ),
              const SizedBox(height: 24),
              
              Text('QUICK ACTIONS', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 12),
              
              Column(
                children: controller.quickActions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
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
              const SizedBox(height: 24),
              
              const ChartSection(),
              const SizedBox(height: 20),
              AnomaliesCard(anomalies: controller.anomalies),
              const SizedBox(height: 20),
              LiveActivityCard(activities: controller.activities),
                  ],
                ),
              ),
      ),
    );
  }
}
