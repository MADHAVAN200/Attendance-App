import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../../../shared/services/dashboard_provider.dart'; // Import Provider
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/models/dashboard_model.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../tablet/widgets/stat_card.dart';
import '../../tablet/widgets/action_card.dart';
import '../../tablet/widgets/activity_feed.dart';
import '../../tablet/widgets/trends_chart.dart';
import '../../tablet/widgets/anomalies_card.dart';
import '../../dashboard.dart'; // Keep for DashboardLogic.quickActions/anomalies
import '../../../../shared/navigation/navigation_controller.dart'; 
import '../../../policy_engine/tablet/views/policy_engine_view.dart'; 
import '../../widgets/employee_dashboard_widgets.dart';

class MobileDashboardContent extends StatelessWidget {
  const MobileDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user.isEmployee) {
      return const MobileEmployeeDashboardContent();
    }
    return const MobileAdminDashboardContent();
  }
}

class MobileEmployeeDashboardContent extends StatelessWidget {
  const MobileEmployeeDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               // 1. Hero
               EmployeeHero(
                userName: user?.name ?? 'Employee', 
                onAttendanceTap: () => navigateTo(PageType.myAttendance), 
                onHolidayTap: () => navigateTo(PageType.leavesAndHolidays),
              ),
              const SizedBox(height: 24),

              // 2. Stats Grid (2x2)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, // Adjust for portrait
                children: [
                  EmployeeStatCard(
                    label: 'Present Days',
                    value: stats.presentToday.toString(),
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF10B981),
                  ),
                  EmployeeStatCard(
                    label: 'Absent Days',
                    value: stats.absentToday.toString(),
                    icon: Icons.cancel_outlined,
                    iconColor: const Color(0xFFEF4444),
                  ),
                  EmployeeStatCard(
                    label: 'Late Arrivals',
                    value: stats.lateCheckins.toString(),
                    icon: Icons.access_time,
                    iconColor: const Color(0xFFF59E0B),
                  ),
                  const EmployeeStatCard(
                    label: 'Leave Balance',
                    value: '8', // Mock
                    badgeText: 'Yearly',
                    icon: Icons.coffee,
                    iconColor: Color(0xFF3B82F6),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Info Cards (Stacked)
              EmployeeInfoCard(
                title: 'Your Work Location',
                icon: Icons.location_on_outlined,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    'Standard locations. Ensure you are within the geofence.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[400] 
                          : Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              EmployeeInfoCard(
                title: 'Policies & Reminders',
                icon: Icons.info_outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint(context, 'Mark attendance before 09:30 AM.'),
                    const SizedBox(height: 12),
                    _buildBulletPoint(context, 'Apply for leave 2 days prior.'),
                  ],
                ),
              ),
               const SizedBox(height: 80), // Bottom padding
            ],
          ),
        );
      }
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: CircleAvatar(radius: 3, backgroundColor: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey[300] 
                  : Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class MobileAdminDashboardContent extends StatefulWidget {
  const MobileAdminDashboardContent({super.key});

  @override
  State<MobileAdminDashboardContent> createState() => _MobileAdminDashboardContentState();
}

class _MobileAdminDashboardContentState extends State<MobileAdminDashboardContent> {
  
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

        final subTextColor = Theme.of(context).textTheme.bodySmall?.color;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            
            // 1. KPI Section (Vertical Stack)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMobileKPIStack(provider.stats, provider.trends),
                  const SizedBox(height: 32),
                ]),
              ),
            ),

            // 2. Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: DashboardLogic.quickActions.map((action) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildQuickActionItem(
                            context, 
                            action['title'], 
                            action['icon'], 
                            action['color'],
                            () {
                              if (action['page'] != null) {
                                if (action['initialTab'] != null) {
                                  PolicyEngineView.initialTabNotifier.value = action['initialTab'] as int;
                                }
                                navigateTo(action['page'] as PageType);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 3. Analytics
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Analytics',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Chart
                   SizedBox(
                    height: 300,
                    child: TrendsChart(chartData: provider.chartData),
                  ),
                  const SizedBox(height: 24),
                  // Activity Feed
                  ActivityFeed(activities: provider.activities),
                  const SizedBox(height: 24),
                  // Anomalies Card
                  AnomaliesCard(anomalies: DashboardLogic.anomalies), 
                  const SizedBox(height: 40), 
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileKPIStack(DashboardStats stats, DashboardTrends trends) {
    // Map stats to List for easy rendering locally
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
        'value': '4', // Static for now or add to model
        'total': 'Planned',
        'percentage': '',
        'context': 'Monthly',
        'isPositive': true,
        'icon': Icons.calendar_today,
        'color': const Color(0xFF6366F1),
      },
    ];

    return Column(
      children: kpis.map((data) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 125,
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
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
