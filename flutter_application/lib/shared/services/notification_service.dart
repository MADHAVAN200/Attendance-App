import 'package:flutter/foundation.dart';
import '../../services/feedback_service.dart';
import '../models/notification_model.dart';
import '../../services/auth_service.dart';

class NotificationService extends ChangeNotifier {
  final AuthService _authService;
  final FeedbackService _feedbackService = FeedbackService();
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationService(this._authService);

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    _isLoading = true;
    if (refresh) notifyListeners(); // Only notify if full refresh to show spinner

    try {
      final list = await _feedbackService.getNotifications(limit: 20);
      _notifications = list.map((e) => NotificationModel.fromJson(e)).toList();
      // Assume API returns unread_count in a wrapper if needed, 
      // but FeedbackService currently returns List<dynamic> directly from data['data'].
      // If we need 'unread_count', we might need to update FeedbackService to return wrapper.
      // Checking FeedbackService... it returns data['data'].
      // To get 'unread_count', I should update FeedbackService to return the full map or a custom object.
      // For now, I'll calculate unread count locally or assume it's missing.
      _unreadCount = _notifications.where((n) => !n.isRead).length; 
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      // Optimistic Update
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, 999);
        notifyListeners();
      }

      await _feedbackService.markAsRead(notificationId);
    } catch (e) {
       print('Error marking notification read: $e');
    }
  }

  Future<void> markAllAsRead() async {
     try {
       // Optimistic Update
       _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true, 
          createdAt: n.createdAt,
       )).toList();
       
       _unreadCount = 0;
       notifyListeners();

       await _feedbackService.markAllRead();
     } catch (e) {
       print('Error marking all notifications read: $e');
     }
  }
}
