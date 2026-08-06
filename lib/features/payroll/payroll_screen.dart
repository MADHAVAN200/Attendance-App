import 'package:flutter/material.dart';
import '../../shared/layout/responsive_layout.dart';
import 'mobile/views/payroll_screen_mobile.dart';
import 'tablet/views/payroll_screen_tablet.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: PayrollScreenMobile(),
      tabletPortrait: PayrollScreenTablet(),
      tabletLandscape: PayrollScreenTablet(),
    );
  }
}
