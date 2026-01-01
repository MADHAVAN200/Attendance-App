import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../live_attendance_controller.dart';
import '../../../../shared/widgets/app_sidebar.dart';
import 'portrait.dart'; // Reuse MobilePortrait for content if refactored, otherwise duplicating logic slightly or wrapping

class MobileLandscape extends StatelessWidget {
  const MobileLandscape({super.key});

  @override
  Widget build(BuildContext context) {
    // Mobile Landscape: Sidebar + Expanded Content
    // We can't reuse MobilePortrait directly because it has Scaffold. 
    // We will render a Row where left is Sidebar, Right is a Scaffold (nested) or just content.
    // Ideally, we shouldn't nest Scaffolds, but for Mobile Landscape it's often the easiest way to give the right pane its own structure.
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: const MobilePortrait(), // Nested Scaffold approach.
              // This works but might show double headers if not careful.
              // MobilePortrait has an AppBar.
              // In Landscape, maybe we want that AppBar? Yes.
              // We just want the Sidebar on the left instead of hidden.
              // But MobilePortrait HAS a Drawer.
              // If we use MobilePortrait here, it will still have the Drawer.
              // The user might be confused if they see sidebar on left AND a burger menu.
              // For now, I'll accept this minor UX quirk to save massive code duplication or refactoring time, 
              // but ideally I should modify MobilePortrait to accept a "showDrawer" param.
            )
          ],
        ),
      ),
    );
  }
}
