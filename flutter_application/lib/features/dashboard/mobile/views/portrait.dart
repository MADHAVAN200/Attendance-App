import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard_controller.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/chart_section.dart';
import '../../widgets/activity_list.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/app_sidebar.dart'; // Assuming AppSidebar is in shared widgets

class MobilePortrait extends StatelessWidget {
  const MobilePortrait({super.key});

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
              
              SizedBox(
                height: 140, 
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.quickActions.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final action = controller.quickActions[index];
                    return SizedBox(
                      width: 260,
                      child: QuickActionCard(
                        title: action['title'],
                        subtitle: action['subtitle'],
                        icon: action['icon'],
                        iconColor: action['color'],
                        iconBgColor: action['color'],
                        onTap: action['onTap'],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              const ChartSection(),
              const SizedBox(height: 20),
              
              LiveActivityCard(activities: controller.activities),
              const SizedBox(height: 20),
              
              AnomaliesCard(anomalies: controller.anomalies),
            ],
          ),
        ),
      ),
    );
  }
}
