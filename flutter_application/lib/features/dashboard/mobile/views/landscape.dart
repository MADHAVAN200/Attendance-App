import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/dashboard_provider.dart';
import '../../../../shared/models/dashboard_model.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/navigation/navigation_controller.dart';
import '../../dashboard.dart';
// Corrected Imports
import '../../tablet/widgets/action_card.dart';
import '../../tablet/widgets/activity_feed.dart';
import '../../tablet/widgets/anomalies_card.dart';
import '../../tablet/widgets/stat_card.dart';
import '../../tablet/widgets/trends_chart.dart';

// Corrected relative imports for other views
// Corrected relative imports for other views
import '../../../employees/mobile/views/employees_mobile_view.dart';
import '../../../attendance/mobile/views/my_attendance_view.dart';
import '../../../live_attendance/mobile/views/live_attendance_view.dart';
import '../../../reports/mobile/views/reports_view.dart';
import '../../../holidays/mobile/views/holidays_view.dart';
import '../../../geo_fencing/mobile/views/geo_fencing_view.dart';

class MobileLandscape extends StatelessWidget {
  const MobileLandscape({super.key});

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
              : [const Color(0xFFF1F5F9), const Color(0xFFCBD5E1)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: AppSidebar(
          onLinkTap: () => Navigator.pop(context),
        ),
        body: ValueListenableBuilder<PageType>(
          valueListenable: navigationNotifier,
          builder: (context, currentPage, _) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CustomAppBar(
                title: currentPage.title,
                showDrawerButton: true,
              ),
              body: _buildContent(context, currentPage),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PageType page) {
    switch (page) {
      case PageType.dashboard:
        return const MobileDashboardLandscapeContent();
      
      case PageType.employees:
         return const EmployeesMobileView();
      
      case PageType.myAttendance:
         return const MobileMyAttendanceContent();
      
      case PageType.liveAttendance:
          return const MobileLiveAttendanceContent();

      case PageType.reports:
          return const MobileReportsContent();

      case PageType.holidays:
          return const MobileHolidaysContent();

      case PageType.geoFencing:
        return const MobileGeoFencingContent();

      case PageType.policyEngine:
      case PageType.profile:
         return Center(child: Text('${page.title} (Landscape)'));
    }
  }
}

class MobileDashboardLandscapeContent extends StatefulWidget {
  const MobileDashboardLandscapeContent({super.key});

  @override
  State<MobileDashboardLandscapeContent> createState() => _MobileDashboardLandscapeContentState();
}

class _MobileDashboardLandscapeContentState extends State<MobileDashboardLandscapeContent> {
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKPISection(provider.stats, provider.trends),
              const SizedBox(height: 24),

              _buildQuickActions(),
              const SizedBox(height: 24),

              _buildAnalyticsSection(provider),
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
        'isPositive': trends.absent.startsWith('-'), // Decreasing absence is positive
        'icon': Icons.cancel_outlined,
        'color': const Color(0xFFEF4444),
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
        'value': '4', // Static for now
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
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
               height: 100, 
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
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2, 
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

  Widget _buildAnalyticsSection(DashboardProvider provider) {
    return Column(
      children: [
         SizedBox(
          height: 300,
          child: TrendsChart(chartData: provider.chartData),
        ),
        const SizedBox(height: 24),
        ActivityFeed(activities: provider.activities),
        const SizedBox(height: 24),
        AnomaliesCard(anomalies: DashboardLogic.anomalies),
      ],
    );
  }
}
