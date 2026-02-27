import 'package:flutter/material.dart';
import 'package:flutter_application/shared/widgets/notification_list.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: const NotificationList(isMobilePage: true),
    );
  }
}

// [mod:2026-02-27T14:00:00+05:30]
