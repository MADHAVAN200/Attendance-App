import 'package:flutter/material.dart';
import 'portrait.dart';
import 'landscape.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape) {
          return const FeedbackTabletLandscape();
        } else {
          return const FeedbackTabletPortrait();
        }
      },
    );
  }
}
