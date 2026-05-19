import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/dashboard_provider.dart';
import '../../../../shared/models/dashboard_model.dart';
import '../../../../shared/navigation/navigation_controller.dart'; 
import '../../dashboard.dart';
import '../widgets/action_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/stat_card.dart';
import '../widgets/trends_chart.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
         if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: KPI Cards
              _buildKPISection(provider.stats, provider.trends),
              const SizedBox(height: 32),

              // Row 2: Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 32),

              // Row 3: Split View (Chart & Feed)
              _buildSplitView(provider),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Widget _buildKPISection(DashboardStats stats, DashboardTrends trends) {
    final kpis = [
      {
        'title': 'Present Today',
        'value': stats.presentToday.toString(),
        'total': '/ ${stats.totalEmployees}',
        'percentage': trends.present.startsWith('-') ? trends.present : '+${trends.present}',
        'context': 'vs yesterday',
        'isPositive': !trends.present.startsWith('-'),
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Absent',
        'value': stats.absentToday.toString(),
        'total': 'Employees',
        'percentage': trends.absent.startsWith('-') ? trends.absent : '+${trends.absent}',
        'context': 'vs yesterday',
        'isPositive': trends.absent.startsWith('-'), 
        'icon': Icons.cancel_outlined,
        'color': const Color(0xFFEF4444), // Red
      },
      {
        'title': 'Late Check-ins',
        'value': stats.lateCheckins.toString(),
        'total': 'Employees',
        'percentage': trends.late,
        'context': 'vs yesterday',
        'isPositive': trends.late.startsWith('-'),
        'icon': Icons.access_time,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'On Leave',
        'value': '4',
        'total': 'Planned',
        'percentage': '',
        'context': 'Monthly',
        'isPositive': true,
        'icon': Icons.calendar_today,
        'color': const Color(0xFF6366F1),
      },
    ];

    return Row(
      children: kpis.map((data) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10), // Gutter
             child: SizedBox(
               height: 140, // Fixed height to constrain Expanded child
               child: StatCard(
                title: data['title'] as String,
                value: data['value'] as String,
                total: data['total'] as String,
                percentage: data['percentage'] as String,
                contextText: data['context'] as String,
                isPositive: data['isPositive'] as bool,
                icon: data['icon'] as IconData,
                baseColor: data['color'] as Color,
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
               onTap: () {
                  if (data['page'] != null) {
                    navigateTo(data['page'] as PageType);
                  }
               },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSplitView(DashboardProvider provider) {
    // Always use Column layout as per user request for Tablet Landscape
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: TrendsChart(chartData: provider.chartData),
        ),
        const SizedBox(height: 32),
        // ActivityFeed grows naturally in Column, no fixed height needed
        ActivityFeed(
          activities: provider.activities,
        ),
      ],
    );
  }
}
