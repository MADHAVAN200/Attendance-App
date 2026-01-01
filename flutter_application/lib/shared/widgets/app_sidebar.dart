import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/navigation_controller.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 280, 
      color: Theme.of(context).drawerTheme.backgroundColor ?? Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                   _buildNavItem(context, nav, index: 0, icon: Icons.dashboard_outlined, label: 'Dashboard'),
                   _buildNavItem(context, nav, index: 1, icon: Icons.access_time, label: 'Live Attendance'),
                   _buildNavItem(context, nav, index: 2, icon: Icons.schedule, label: 'My Attendance'),
                   _buildNavItem(context, nav, index: 3, icon: Icons.people_outline, label: 'Employees'),
                   _buildNavItem(context, nav, index: 4, icon: Icons.trending_up, label: 'Reports'),
                   _buildNavItem(context, nav, index: 5, icon: Icons.event_note, label: 'Holidays'),
                   _buildNavItem(context, nav, index: 6, icon: Icons.settings_outlined, label: 'Policy Engine'),
                   _buildNavItem(context, nav, index: 7, icon: Icons.location_on_outlined, label: 'Geo Fencing'),
                ],
              ),
            ),
          ),
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Row(
        children: [
          // Fallback logo if asset fails or simplified version
          Image.asset(
           'assets/mano.png',
           height: 32,
           errorBuilder: (c, o, s) => const Icon(Icons.change_history, size: 32, color: Color(0xFF5B60F6)),
          ),
          const SizedBox(width: 12),
          Text(
            'MANO',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF5B60F6),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavigationController nav, {required int index, required IconData icon, required String label}) {
    final isActive = nav.selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final color = isActive ? const Color(0xFF5B60F6) : (isDark ? Colors.grey[400] : const Color(0xFF6B7280));
    final bgColor = isActive ? const Color(0xFF5B60F6).withOpacity(isDark ? 0.2 : 0.1) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => nav.setIndex(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(Icons.logout, color: color, size: 22),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
