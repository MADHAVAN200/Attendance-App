import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/shared/navigation/navigation_controller.dart';
import 'package:flutter_application/features/policy_engine/views/policy_engine_tablet_portrait_view.dart';
import 'package:flutter_application/features/geo_fencing/views/geo_fencing_tablet_portrait_view.dart';
import 'package:flutter_application/features/policies/widgets/salary_packages_tab_view.dart';

class PoliciesTabletLandscapeView extends StatefulWidget {
  final String? initialTab;
  const PoliciesTabletLandscapeView({super.key, this.initialTab});

  @override
  State<PoliciesTabletLandscapeView> createState() => _PoliciesTabletLandscapeViewState();
}

class _PoliciesTabletLandscapeViewState extends State<PoliciesTabletLandscapeView> {
  late String _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab ?? policiesTabNotifier.value;
    policiesTabNotifier.addListener(_syncTab);
  }

  @override
  void dispose() {
    policiesTabNotifier.removeListener(_syncTab);
    super.dispose();
  }

  void _syncTab() {
    if (mounted && policiesTabNotifier.value != _currentTab) {
      setState(() => _currentTab = policiesTabNotifier.value);
    }
  }

  void _setTab(String tab) {
    setState(() => _currentTab = tab);
    policiesTabNotifier.value = tab;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Strip Header - Exactly formatted like Attendance-Web
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabButton('shifts', 'Shift Management', Icons.access_time_rounded, isDark),
                const SizedBox(width: 4),
                _buildTabButton('geofencing', 'Geo Fencing', Icons.location_on_outlined, isDark),
                const SizedBox(width: 4),
                _buildTabButton('salary_packages', 'Salary Packages', Icons.layers_outlined, isDark),
              ],
            ),
          ),
        ),

        // Tab Body
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildTabContent(_currentTab),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String tabKey, String label, IconData icon, bool isDark) {
    final isSelected = _currentTab == tabKey;

    return InkWell(
      onTap: () => _setTab(tabKey),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF334155) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? (isDark ? const Color(0xFFF0F6FC) : const Color(0xFF0969DA))
                  : (isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? const Color(0xFFF0F6FC) : const Color(0xFF0969DA))
                    : (isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(String tab) {
    switch (tab) {
      case 'geofencing':
        return const GeoFencingView(key: ValueKey('geofencing'));
      case 'salary_packages':
        return const SalaryPackagesTabView(key: ValueKey('salary_packages'));
      case 'shifts':
      default:
        return const PolicyEngineView(key: ValueKey('shifts'));
    }
  }
}

// [upd:2026-04-09T11:00:00+05:30]
