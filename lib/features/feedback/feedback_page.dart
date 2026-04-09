import 'package:flutter/material.dart';
import 'package:flutter_application/features/feedback/views/feedback_mobile_portrait_view.dart';
import 'package:flutter_application/features/feedback/views/feedback_tablet_portrait_view.dart';
import 'package:flutter_application/features/feedback/views/feedback_tablet_landscape_view.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const FeedbackMobileView();
        }
        return OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return const FeedbackTabletLandscape();
            } else {
              return const FeedbackTabletPortrait();
            }
          },
        );
      },
    );
  }
}

typedef FeedbackView = FeedbackPage;

// [upd:2026-04-09T11:00:00+05:30]
