import 'package:flutter/material.dart';
import 'package:flutter_application/features/profile/views/profile_mobile_portrait_view.dart';
import 'package:flutter_application/features/profile/views/profile_tablet_portrait_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileProfileContent();
        }
        return const ProfileView();
      },
    );
  }
}

// [mod:2026-02-27T09:00:00+05:30]

// [upd:2026-04-29T17:00:00+05:30]

// [upd:2026-05-13T11:30:00+05:30]
