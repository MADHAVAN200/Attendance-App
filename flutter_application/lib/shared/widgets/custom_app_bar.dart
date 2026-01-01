import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_simple.dart';
import 'glass_container.dart';
import '../navigation/navigation_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showDrawerButton;
  final String title;

  const CustomAppBar({
    super.key, 
    this.showDrawerButton = true,
    this.title = 'Dashboard',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (showDrawerButton)
            IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).iconTheme.color),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const Spacer(),
          
          // Theme Switcher Button
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark; 
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  toggleTheme();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          // Admin User Profile
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 60),
              color: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              enableFeedback: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tooltip: 'Profile Options',
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false, 
                  padding: EdgeInsets.zero,
                  child: GlassContainer(
                    width: 220,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDropdownItem(context, icon: Icons.person_outline, text: 'View Profile', onTap: () {
                           navigationNotifier.value = PageType.profile;
                           Navigator.pop(context);
                        }),
                        Divider(height: 1, thickness: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey[200]),
                        _buildDropdownItem(context, icon: Icons.logout, text: 'Logout', onTap: () {
                          Navigator.pop(context);
                          // Implement logout logic here
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
                        }, isDestructive: true),
                      ],
                    ),
                  ),
                )
              ],
              child: Row(
                children: [
                   Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text(
                        'Admin User',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'Administrator',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF5B60F6).withOpacity(0.2),
                    child: Text('AU', style: GoogleFonts.poppins(color: const Color(0xFF5B60F6), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap, bool isDestructive = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
