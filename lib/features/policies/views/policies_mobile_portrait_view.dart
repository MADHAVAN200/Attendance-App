import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/shared/navigation/navigation_controller.dart';
import 'package:flutter_application/features/policy_engine/views/policy_engine_tablet_portrait_view.dart';
import 'package:flutter_application/features/geo_fencing/views/geo_fencing_mobile_portrait_view.dart';
import 'package:flutter_application/features/policies/widgets/salary_packages_tab_view.dart';

class PoliciesMobileView extends StatefulWidget {
  final String? initialTab;
  const PoliciesMobileView({super.key, this.initialTab});

  @override
  State<PoliciesMobileView> createState() => _PoliciesMobileViewState();
}

class _PoliciesMobileViewState extends State<PoliciesMobileView> {
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
      children: [
        // Mobile Segmented Pill Strip
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            children: [
              _buildTabPill('shifts', 'Shifts', Icons.access_time_rounded, isDark),
              _buildTabPill('geofencing', 'Geo', Icons.location_on_outlined, isDark),
              _buildTabPill('salary_packages', 'Packages', Icons.payments_outlined, isDark),
            ],
          ),
        ),

        // Active Tab Content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildTabContent(_currentTab),
          ),
        ),
      ],
    );
  }

  Widget _buildTabPill(String tabKey, String label, IconData icon, bool isDark) {
    final isSelected = _currentTab == tabKey;

    return Expanded(
      child: GestureDetector(
        onTap: () => _setTab(tabKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF21262D) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : (isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : (isDark ? const Color(0xFF8B949E) : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String tab) {
    switch (tab) {
      case 'geofencing':
        return const MobileGeoFencingContent(key: ValueKey('geofencing'));
      case 'salary_packages':
        return const SalaryPackagesTabView(key: ValueKey('salary_packages'));
      case 'shifts':
      default:
        return const PolicyEngineView(key: ValueKey('shifts'));
    }
  }
}

// [upd:2026-04-09T08:30:00+05:30]
