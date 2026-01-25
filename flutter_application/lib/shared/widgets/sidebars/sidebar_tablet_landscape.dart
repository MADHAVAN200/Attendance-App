import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../navigation/navigation_controller.dart';
import '../glass_container.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SidebarTabletLandscape extends StatelessWidget {
  final VoidCallback? onLinkTap;

  const SidebarTabletLandscape({super.key, this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    // Fixed Sidebar for Landscape
    return GlassContainer(
      width: 280,
      height: double.infinity,
      blur: 0, 
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF101828) // Standardized Dark Mode Color
          : const Color(0xFFFFFFFF),
      borderRadius: 0, 
      child: _SidebarContent(onLinkTap: onLinkTap),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final VoidCallback? onLinkTap;
  const _SidebarContent({this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PageType>(
      valueListenable: navigationNotifier,
      builder: (context, currentPage, _) {
        return Column(
          children: [
            // Fixed Sidebar Header (Aligned with AppBar)
            SafeArea(
              bottom: false,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                     // Logo Icon (Using similar style to provided image if possible, or keeping existing)
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: const Color(0xFF5B60F6).withOpacity(0.1),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: const Icon(Icons.change_history, color: Color(0xFF5B60F6), size: 24),
                     ),
                     const SizedBox(width: 12),
                     Text(
                       'MANO',
                       style: GoogleFonts.poppins(
                         fontSize: 24,
                         fontWeight: FontWeight.bold,
                         color: const Color(0xFF5B60F6), // Match Brand Color
                         letterSpacing: 1.0,
                       ),
                     ),
                  ],
                ),
              ),
            ),
            
            // Scrollable Menu Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24), // Add top spacing for items
                child: Column(
                  children: [
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
                       return p != PageType.profile; // Hide profile
                    }).map((page) => _buildMenuItem(
                      context, 
                      page,
                      currentPage == page,
                    )),
                  ],
                ),
              ),
            ),
          ],
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
            ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        horizontalTitleGap: 8,
        minLeadingWidth: 20,
        leading: Icon(
          page.icon,
          color: isActive 
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.grey : Colors.black54),
        ),
        title: Text(
          page.title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive 
                ? (isDark ? Colors.white : Colors.black)
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
