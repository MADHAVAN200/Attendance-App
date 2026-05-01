import 'package:flutter/material.dart';
import 'package:flutter_application/shared/widgets/notification_list.dart';

class NotificationsTabletPortraitView extends StatelessWidget {
  const NotificationsTabletPortraitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: const NotificationList(isMobilePage: false),
    );
  }
}

// [mod:2026-02-27T14:00:00+05:30]

// [upd:2026-05-01T09:00:00+05:30]
