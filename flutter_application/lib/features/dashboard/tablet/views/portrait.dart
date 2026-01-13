import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/dashboard_provider.dart';
import '../../../../shared/models/dashboard_model.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/navigation/navigation_controller.dart';
import '../../dashboard.dart';
import '../widgets/action_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/anomalies_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/trends_chart.dart';
import '../../../employees/tablet/views/employees_view.dart';
import '../../../attendance/tablet/views/my_attendance_view.dart';
import '../../../live_attendance/tablet/views/live_attendance_view.dart';
import '../../../reports/tablet/views/reports_view.dart';
import '../../../holidays/tablet/views/holidays_view.dart';
import '../../../policy_engine/tablet/views/policy_engine_view.dart';
import '../../../profile/tablet/views/profile_view.dart';

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
        extendBodyBehindAppBar: true, 
        backgroundColor: Colors.transparent, // Transparent to show gradient
        drawer: AppSidebar(
          onLinkTap: () {
            Navigator.pop(context); // Close drawer on selection
          },
        ),
        body: Stack(
          children: [
            // Background Elements could go here
            
            Column(
              children: [
                // Sticky Header
                ValueListenableBuilder<PageType>(
                  valueListenable: navigationNotifier,
                  builder: (context, currentPage, _) {
                    return CustomAppBar(
                      title: currentPage.title,
                      showDrawerButton: true,
                    );
                  }
                ),

                // Scrollable Content Region
                Expanded(
                  child: ValueListenableBuilder<PageType>(
                    valueListenable: navigationNotifier,
                    builder: (context, currentPage, _) {
                      // Dynamic Body Content
                      switch (currentPage) {
                        case PageType.dashboard:
                          return const DashboardContent();
                        case PageType.employees:
                           return const EmployeesView();
                        case PageType.myAttendance:
                           return const MyAttendanceView();
                        case PageType.liveAttendance:
                           return const LiveAttendanceView();
                        case PageType.reports:
                           return const ReportsView();
                        case PageType.holidays:
                           return const HolidaysView();
                        case PageType.policyEngine:
                           return const PolicyEngineView();
                        case PageType.geoFencing:
                           return Center(
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.screen_rotation, size: 64, color: Colors.grey[400]),
                                 const SizedBox(height: 24),
                                 Text(
                                   'Please rotate your device',
                                   style: GoogleFonts.poppins(
                                     fontSize: 20,
                                     fontWeight: FontWeight.w600,
                                     color: isDark ? Colors.white : Colors.black87,
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   'Geo-Fencing features require landscape mode',
                                   style: GoogleFonts.poppins(
                                     fontSize: 14,
                                     color: Colors.grey[500],
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                               ],
                             ),
                           );
                        case PageType.profile:
                           return const ProfileView();
                        default:
                          return Center(child: Text('Page: ${currentPage.title}'));
                      }
                    }
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(PageType page) {
    switch (page) {
      case PageType.dashboard:
        return const DashboardContent();
      case PageType.employees:
        return const EmployeesView();
      default:
        return Center(child: Text('Coming Soon: ${page.title}'));
    }
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
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
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: KPI Cards (Stacked Grid - 2 Column)
              _buildKPISection(provider.stats, provider.trends),
              const SizedBox(height: 24),

              // Section 2: Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Section 3: Trends Chart (Full Width)
               SizedBox(
                height: 400,
                child: TrendsChart(chartData: provider.chartData),
              ),
              const SizedBox(height: 24),

                // Section 4: Live Activity Feed (Full Width)
              ActivityFeed(
                activities: provider.activities,
              ),
              const SizedBox(height: 24),

              // Section 5: Anomalies (Full Width)
              AnomaliesCard(
                anomalies: DashboardLogic.anomalies,
              ),
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cards per row
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.4, // Significantly wider aspect ratio to reduce height
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final data = kpis[index];
        return StatCard(
          title: data['title'] as String,
          value: data['value'] as String,
          total: data['total'] as String,
          percentage: data['percentage'] as String,
          contextText: data['context'] as String,
          isPositive: data['isPositive'] as bool,
          icon: data['icon'] as IconData,
          baseColor: data['color'] as Color,
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
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: DashboardLogic.quickActions.map((data) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ActionCard(
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

