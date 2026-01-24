import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio = Dio();
  late PersistCookieJar _cookieJar;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  String? _accessToken;
  User? _currentUser;

  bool get isAuthenticated => _accessToken != null;
  User? get user => _currentUser;

  // Initialize AuthService
  Future<void> init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _cookieJar = PersistCookieJar(storage: FileStorage("$appDocPath/.cookies/"));
    
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Setup Interceptor for Access Token & Refresh Logic
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized & 403 Forbidden (likely expired access token)
          if ((e.response?.statusCode == 403 || e.response?.statusCode == 401) && _accessToken != null) {
            try {
              final newAccessToken = await refreshToken();
              if (newAccessToken != null) {
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                final clonedReq = await _dio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                    contentType: opts.contentType,
                    responseType: opts.responseType,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(clonedReq);
              } else {
                 // Refresh failed, force logout
                 await logout();
              }
            } catch (refreshError) {
              await logout();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String userInput, String password, String captchaId, String captchaValue) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'user_input': userInput,
        'user_password': password,
        'captchaId': captchaId,
        'captchaText': captchaValue,
      });

      if (response.statusCode == 200) {
        _accessToken = response.data['accessToken'];
        
        // Fetch user details immediately after login
        await getMe();
        
        notifyListeners(); // Notify UI
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Login Failed');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null && e.response!.data is Map) {
         throw Exception(e.response!.data['message'] ?? 'Login Failed');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchCaptcha() async {
    try {
      final response = await _dio.get(ApiConstants.captchaGenerate);
      return response.data;
    } catch (e) {
      print("Detailed Captcha Error: $e");
      throw Exception('Failed to load captcha: $e');
    }
  }

  Future<String?> refreshToken() async {
    try {
      // The cookie is automatically sent by Dio
      final response = await _dio.post(ApiConstants.refresh);
      
      if (response.statusCode == 200) {
        final newToken = response.data['accessToken'];
        _accessToken = newToken;
        // Check if we want to notify listeners on silent refresh? Usually not strictly needed unless UI depends on token
        return newToken;
      }
    } catch (e) {
      print("Refresh failed: $e");
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignore errors during logout
    } finally {
      _accessToken = null;
      _currentUser = null;
      await _cookieJar.deleteAll();
      await _storage.deleteAll();
      notifyListeners(); // Notify UI to redirect
    }
  }

  // Forgot Password Flow
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/forgot-password',
        data: {'email': email},
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response?.data != null && e.response!.data is Map) {
         throw Exception(e.response!.data['message'] ?? 'Failed to send OTP');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response?.data != null && e.response!.data is Map) {
         throw Exception(e.response!.data['message'] ?? 'Invalid OTP');
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/reset-password',
        data: {
          'resetToken': resetToken,
          'newPassword': newPassword,
        },
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
         throw Exception(response.data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null && e.response!.data is Map) {
         throw Exception(e.response!.data['message'] ?? 'Failed to reset password');
      }
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> checkAuthStatus() async {
    try {
      // Mimic React's initAuth: Try refresh first
      final newToken = await refreshToken();
      if (newToken != null) {
        // If refresh successful, fetch user details
        final user = await getMe();
        return user != null ? {'user': user} : null;
      }
    } catch (e) {
      print("Check auth status failed: $e");
    }
    return null;
  }

  Future<User?> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      print("GetMe failed: $e");
    }
    return null;
  }
  
  // Expose Dio client for other services to reuse auth headers/interceptors
  Dio get dio => _dio;
}
