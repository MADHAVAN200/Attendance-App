import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String baseUrl = 'https://attendance.mano.co.in/api';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Keys
  static String get recaptchaSiteKey => dotenv.env['RECAPTCHA_SITE_KEY'] ?? '';
}
