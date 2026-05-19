import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_container.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationList extends StatefulWidget {
  final bool isMobilePage;
  const NotificationList({super.key, this.isMobilePage = false});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when opened
    // Fetch notifications when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<NotificationService>(context, listen: false).fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, service, child) {
        final notifications = service.notifications;
        final isLoading = service.isLoading;
        
        final content = Column(
            children: [
              // Header (Only show if not on separate mobile page)
              if (!widget.isMobilePage) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed: () => service.markAllAsRead(),
                          child: Text('Mark all read', style: GoogleFonts.poppins(fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                const Divider(),
              ],
              
              // List
              Expanded(
                child: isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : notifications.isEmpty 
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('No notifications', style: GoogleFonts.poppins(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: notifications.length,
                          separatorBuilder: (c, i) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return _buildNotificationItem(context, notifications[index], service);
                          },
                        ),
              ),
            ],
          );

        if (widget.isMobilePage) {
           return content; // Return plain content for Scaffold body
        }

        return GlassContainer(
          width: 350,
          height: 400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: content,
        );
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel note, NotificationService service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = note.isRead ? Colors.transparent : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.blue.withValues(alpha: 0.05));
    
    return InkWell(
      onTap: () => service.markAsRead(note.id),
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTypeColor(note.type).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getTypeIcon(note.type), size: 16, color: _getTypeColor(note.type)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: note.isRead ? FontWeight.normal : FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.message,
                    style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                     _formatTime(note.createdAt),
                     style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (!note.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              )
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM dd').format(time);
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'warning': return Colors.orange;
      case 'error': return Colors.red;
      case 'success': return Colors.green;
      default: return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'warning': return Icons.warning_amber_rounded;
      case 'error': return Icons.error_outline;
      case 'success': return Icons.check_circle_outline;
      default: return Icons.info_outline;
    }
  }
}
