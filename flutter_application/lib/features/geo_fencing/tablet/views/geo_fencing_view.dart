import 'package:flutter/material.dart';
import '../../views/geofencing_screen.dart';

class GeoFencingView extends StatelessWidget {
  const GeoFencingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.transparent : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: const GeofencingScreen(),
    );
  }
}
