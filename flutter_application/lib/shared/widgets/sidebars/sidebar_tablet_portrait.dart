import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../navigation/navigation_controller.dart';
import '../glass_container.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SidebarTabletPortrait extends StatelessWidget {
  final VoidCallback? onLinkTap;

  const SidebarTabletPortrait({super.key, this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    // Tablet Portrait Drawer (Usually behaves like a drawer but wider/different style)
    return Drawer(
      width: 300,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassContainer(
        width: double.infinity,
        height: double.infinity,
        blur: 0, 
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF101828) // Standardized Dark Mode Color
            : const Color(0xFFFFFFFF),
        borderRadius: 0, 
        child: _SidebarContent(onLinkTap: onLinkTap),
      ),
    );
  }
}

// Reusing content logic but separating widget for file isolation as requested
class _SidebarContent extends StatelessWidget {
  final VoidCallback? onLinkTap;
  const _SidebarContent({this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PageType>(
      valueListenable: navigationNotifier,
      builder: (context, currentPage, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
            // Sidebar Header
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Icon(Icons.change_history, color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'MANO',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Menu Items
            ...PageType.values.where((p) {
              final user = context.read<AuthService>().user;
              if (user != null && user.isEmployee) {
                  final allowed = [
                    PageType.dashboard,
                    PageType.myAttendance,
                    PageType.leavesAndHolidays,
                    PageType.dailyActivity,
                    PageType.feedback,
                    PageType.profile,
                  ];
                  if (!allowed.contains(p)) return false;
              }
              return p != PageType.profile; // Hide profile in sidebar on tablet
            }).map((page) => _buildMenuItem(
              context, 
              page,
              currentPage == page,
            )),
          ],
          ),
        );
      }
    );
  }

  Widget _buildMenuItem(BuildContext context, PageType page, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF4338CA).withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        horizontalTitleGap: 8,
        minLeadingWidth: 20,
        leading: Icon(
          page.icon,
          color: isActive 
              ? (isDark ? Colors.white : const Color(0xFF4338CA))
              : (isDark ? Colors.grey : Colors.black54),
        ),
        title: Text(
          page.title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive 
                ? (isDark ? Colors.white : const Color(0xFF4338CA))
                : (isDark ? Colors.grey[400] : Colors.black87),
          ),
        ),
        onTap: () {
          navigateTo(page);
          if (onLinkTap != null) onLinkTap!();
        },
      ),
    );
  }
}
