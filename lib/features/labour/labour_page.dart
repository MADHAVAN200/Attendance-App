import 'package:flutter/material.dart';
import 'package:flutter_application/features/labour/views/labour_mobile_portrait_view.dart';
import 'package:flutter_application/features/labour/views/labour_tablet_portrait_view.dart';
import 'package:flutter_application/features/labour/views/labour_tablet_landscape_view.dart';
import 'package:flutter_application/shared/layout/responsive_layout.dart';

class LabourPage extends StatelessWidget {
  const LabourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: LabourMobilePortraitView(),
      tabletPortrait: LabourTabletPortraitView(),
      tabletLandscape: LabourTabletLandscapeView(),
      desktop: LabourTabletLandscapeView(),
    );
  }
}

// [upd:2026-04-13T09:00:00+05:30]

// [upd:2026-05-12T14:00:00+05:30]
