import 'package:flutter/material.dart';
import '../../../../shared/widgets/notification_list.dart';

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
