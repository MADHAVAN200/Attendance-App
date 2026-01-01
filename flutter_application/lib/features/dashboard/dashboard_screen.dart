import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/responsive_builder.dart';
import 'dashboard_controller.dart';
import 'mobile/dashboard_mobile.dart';
import 'tablet/dashboard_tablet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
     // Enable Immersive Mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Restore System UI overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(),
      child: const Scaffold(
        body: ResponsiveBuilder(
          mobile: DashboardMobile(),
          tablet: DashboardTablet(),
        ),
      ),
    );
  }
}
