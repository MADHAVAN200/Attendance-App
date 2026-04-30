import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/shared/services/auth_service.dart';
import 'package:flutter_application/features/geo_fencing/core/location_service.dart';
import 'package:flutter_application/features/geo_fencing/widgets/geofencing_screen.dart';

class MobileGeoFencingContent extends StatelessWidget {
  const MobileGeoFencingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final service = LocationService(authService.dio);

    // Provide the service to the screen
    // We don't need another Provider if we just pass it, OR we can wrap it.
    // Holidays wrapper creates service and passes it. 
    // I can stick to my Provider pattern if I want, or just pass it.
    // Provider is flexible.
    
    return Provider<LocationService>.value(
      value: service,
      child: GeofencingScreen(locationService: service),
    );
  }
}

// commit-marker: 2026-03-18T10:00:00+05:30

// [mod:2026-02-24T11:30:00+05:30]

// [upd:2026-04-30T17:00:00+05:30]
