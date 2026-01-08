import 'package:flutter/material.dart';
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

      case PageType.policyEngine:
      case PageType.geoFencing:
      case PageType.profile:
         return Center(child: Text('${page.title} (Landscape)'));
    }
  }
}

class MobileDashboardLandscapeContent extends StatelessWidget {
  const MobileDashboardLandscapeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPISection(),
          const SizedBox(height: 24),

          _buildQuickActions(),
          const SizedBox(height: 24),

          _buildAnalyticsSection(),
        ],
      ),
    );
  }

  Widget _buildKPISection() {
    return Row(
      children: DashboardLogic.kpiData.map((data) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
               height: 100, 
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    // TrendsChart might not be const, ActivityFeed might not be const depending on implementation.
    // Removed const to be safe based on error logs.
    return Column(
      children: [
        const SizedBox(
          height: 300,
          child: TrendsChart(),
        ),
        const SizedBox(height: 24),
        ActivityFeed(activities: DashboardLogic.recentActivity),
        const SizedBox(height: 24),
        AnomaliesCard(anomalies: DashboardLogic.anomalies),
      ],
    );
  }
}
