import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/navigation_controller.dart';
import 'glass_container.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../services/auth_service.dart'; // Import AuthService

class AppSidebar extends StatelessWidget {
  final VoidCallback? onLinkTap;

  const AppSidebar({
    super.key, 
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Glassmorphism Sidebar
    return GlassContainer(
      width: isMobile ? 240 : 280,
      height: double.infinity,
      blur: 60, // Stronger blur for iOS frosted effect
      color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black.withOpacity(0.2) // Explicit iOS dark glass
          : Colors.white, // Solid White for Light Mode
      borderRadius: 0, 
      child: ValueListenableBuilder<PageType>(
        valueListenable: navigationNotifier,
        builder: (context, currentPage, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
              // Sidebar Header (Matches CustomAppBar)
              Container(
                height: 70,
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
                    // Optional Logo Icon
                    Icon(
                      Icons.change_history, // Placeholder logo icon
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
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
              
              const SizedBox(height: 16), // Matches typical page content padding
              
              // Menu Items
              ...PageType.values.where((p) {
                // 1. Role-based Filtering
                final user = context.read<AuthService>().user;
                if (user != null && user.isEmployee) {
                   // Employee Allowed Pages
                   final allowed = [
                     PageType.dashboard,
                     PageType.myAttendance,
                     PageType.applyLeave,
                     PageType.holidays,
                     PageType.profile,
                   ];
                   if (!allowed.contains(p)) return false;
                }

                // 2. Mobile Logic
                if (isMobile) return true; // Show all (filtered) on mobile
                return p != PageType.profile; // Hide profile on tablet/desktop (sidebar)
              }).map((page) => _buildMenuItem(
                context, 
                page,
                currentPage == page,
              )),
            ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, PageType page, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), // Reduced vertical margin
      decoration: BoxDecoration(
        color: isActive 
            ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)) // Neutral grey for light mode active
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true, // Reduces internal vertical padding
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Explicit padding control
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2), // Further reduce height
        horizontalTitleGap: 8,
        minLeadingWidth: 20,
        leading: Icon(
          page.icon,
          size: 20, // Verify icon size
          color: isActive 
              ? (isDark ? Colors.white : Colors.black) // Black for light mode active
              : (isDark ? Colors.grey : Colors.black54),
        ),
        title: Text(
          page.title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive 
                ? (isDark ? Colors.white : Colors.black) // Black for light mode active
                : (isDark ? Colors.grey[400] : Colors.black87),
          ),
        ),
        onTap: () {
          navigateTo(page);
          onLinkTap?.call();
        },
      ),
    );
  }
}

