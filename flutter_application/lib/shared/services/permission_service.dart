import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionService {
  Future<void> requestInitialPermissions() async {
    // Skip on unsupported platforms to avoid MissingPluginException
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('PermissionService: Skipping permissions on this platform');
      return;
    }

    // Request multiple permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.notification,
      // For storage:
      // Android 13+ uses photos/videos/audio permissions instead of storage
      if (Platform.isAndroid) ...[
          Permission.storage, // For <= Android 12
          Permission.photos,  // For Android 13+
          Permission.videos,  // For Android 13+
      ],
      if (Platform.isIOS) ...[
         Permission.photos,
         Permission.storage, 
      ]
    ].request();

    // Log results for debugging
    statuses.forEach((permission, status) {
      debugPrint('PermissionService: $permission -> $status');
    });
    
    // Optional: Handle permanently denied permissions if needed
    // e.g., if (statuses[Permission.camera]!.isPermanentlyDenied) { ... }
  }
}
