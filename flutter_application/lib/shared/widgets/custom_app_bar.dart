import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showDrawerButton;
  final Color backgroundColor;

  const CustomAppBar({
    super.key, 
    this.showDrawerButton = true,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();
    final title = _getTitle(nav.selectedIndex);

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      centerTitle: false,
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: showDrawerButton 
        ? Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, size: 24, color: Theme.of(context).iconTheme.color),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
        : null,
      actions: [
        // Dark Mode Toggle
        Consumer<ThemeController>(
          builder: (context, themeController, _) {
            return IconButton(
              icon: Icon(
                themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => themeController.toggleTheme(),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: 24, color: Theme.of(context).iconTheme.color),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFE2E8F0),
          child: Icon(Icons.person, size: 20, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Dashboard';
      case 1: return 'Live Attendance';
      case 2: return 'My Attendance';
      case 3: return 'Employees';
      case 4: return 'Reports';
      case 5: return 'Holidays';
      case 6: return 'Policy Engine';
      case 7: return 'Geo Fencing';
      case 8: return 'Profile';
      default: return 'MANO';
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
