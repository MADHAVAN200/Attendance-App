import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/layout/main_layout.dart';
import 'tablet/views/portrait.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force Immersive Mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return const TabletPortrait();
        } else {
          return const MainLayout();
        }
      },
    );
  }
}
