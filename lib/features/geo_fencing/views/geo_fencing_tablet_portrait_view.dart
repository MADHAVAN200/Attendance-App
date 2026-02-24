import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/shared/services/auth_service.dart';
import 'package:flutter_application/features/geo_fencing/core/location_service.dart';
import 'package:flutter_application/features/geo_fencing/widgets/geofencing_screen.dart';

class GeoFencingView extends StatelessWidget {
  const GeoFencingView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final service = LocationService(authService.dio);
    
    return Provider<LocationService>.value(
      value: service,
      child: GeofencingScreen(locationService: service),
    );
  }
}

// [mod:2026-02-24T11:30:00+05:30]
