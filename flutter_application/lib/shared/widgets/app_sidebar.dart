import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/navigation_controller.dart';
import 'glass_container.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Glassmorphism Sidebar
    return GlassContainer(
      width: 280,
      borderRadius: 0, // Sidebar usually square corners on left or handled by parent. 
      // But standard glass has borders. Let's keep 0 for side-attached look or small radius.
      // Actually usually sidebars are full height. GlassContainer has borderRadius. 
      // Let's set it to 0 or leave defaults. For a sidebar, maybe 0?
      // Let's use 0 for now as it attaches to the side.
      blur: 8, // Reduced blur for better glass effect
      child: ValueListenableBuilder<PageType>(
        valueListenable: navigationNotifier,
        builder: (context, currentPage, _) {
          return Column(
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
              
              const SizedBox(height: 32), // Matches typical page content padding
              
              // Menu Items
              ...PageType.values.where((p) => p != PageType.profile).map((page) => _buildMenuItem(
                context, 
                page,
                currentPage == page,
              )),
            ],
          );
        }
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, PageType page, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? (isDark ? Colors.white.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        horizontalTitleGap: 8,
        minLeadingWidth: 20,
        leading: Icon(
          page.icon,
          color: isActive 
              ? (isDark ? Colors.white : Theme.of(context).primaryColor)
              : Colors.grey,
        ),
        title: Text(
          page.title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive 
                ? (isDark ? Colors.white : Theme.of(context).primaryColor)
                : (isDark ? Colors.grey[400] : Theme.of(context).primaryColor), // Inactive text, keep readable
          ),
        ),
        onTap: () {
          navigateTo(page);
        },
      ),
    );
  }
}
