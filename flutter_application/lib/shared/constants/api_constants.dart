import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String baseUrl = 'https://attendance.mano.co.in/api';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markRead = '/notifications/:id/read';
  static const String readAll = '/notifications/read-all';

  // Dashboard
  static const String dashboardStats = '/admin/dashboard-stats';
  static const String captchaGenerate = '/auth/captcha/generate';

  // Keys
  static String get recaptchaSiteKey => dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';
}
