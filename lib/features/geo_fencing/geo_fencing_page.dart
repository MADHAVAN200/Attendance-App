import 'package:flutter/material.dart';
import 'package:flutter_application/features/geo_fencing/views/geo_fencing_mobile_portrait_view.dart';
import 'package:flutter_application/features/geo_fencing/views/geo_fencing_tablet_portrait_view.dart';

class GeoFencingPage extends StatelessWidget {
  const GeoFencingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const MobileGeoFencingContent();
        }
        return const GeoFencingView();
      },
    );
  }
}

// [mod:2026-02-24T09:00:00+05:30]

// [upd:2026-04-24T14:00:00+05:30]

// [upd:2026-05-06T14:00:00+05:30]

// [upd:2026-05-12T14:00:00+05:30]
