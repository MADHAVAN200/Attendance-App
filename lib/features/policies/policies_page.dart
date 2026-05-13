import 'package:flutter/material.dart';
import 'package:flutter_application/shared/layout/responsive_layout.dart';
import 'package:flutter_application/features/policies/views/policies_mobile_portrait_view.dart';
import 'package:flutter_application/features/policies/views/policies_tablet_portrait_view.dart';
import 'package:flutter_application/features/policies/views/policies_tablet_landscape_view.dart';

class PoliciesView extends StatelessWidget {
  final String? initialTab;
  const PoliciesView({super.key, this.initialTab});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: PoliciesMobileView(initialTab: initialTab),
      tabletPortrait: PoliciesTabletPortraitView(initialTab: initialTab),
      tabletLandscape: PoliciesTabletLandscapeView(initialTab: initialTab),
      desktop: PoliciesTabletLandscapeView(initialTab: initialTab),
    );
  }
}

// [upd:2026-04-09T08:30:00+05:30]

// [upd:2026-05-13T09:00:00+05:30]
