import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import '../shared/constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final Dio _dio = Dio();
  late PersistCookieJar _cookieJar;
  String? _accessToken;
  bool _isInitialized = false;

  Dio get dio => _dio;
  String? get accessToken => _accessToken;

  Future<void> init() async {
    if (_isInitialized) return;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    _cookieJar = PersistCookieJar(storage: FileStorage("$appDocPath/.cookies/"));

    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    _dio.interceptors.add(CookieManager(_cookieJar));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401/403 - Token Expiration
          if ((e.response?.statusCode == 403 || e.response?.statusCode == 401) && _accessToken != null) {
            try {
              // Lock interceptor to prevent multiple refreshes? 
              // For simplicity, just try refresh
              final newAccessToken = await _refreshToken();
              if (newAccessToken != null) {
                _accessToken = newAccessToken;
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
              }
            } catch (_) {
              // Refresh failed, let the error propagate or logout
            }
          }
          return handler.next(e);
        },
      ),
    );

    _isInitialized = true;
  }

  Future<String?> _refreshToken() async {
    try {
      // Create a separate Dio instance or use base options to avoid interceptor loop
      // But here we rely on the cookie being sent automatically
      final response = await _dio.post(ApiConstants.refresh);
      if (response.statusCode == 200) {
        return response.data['accessToken'];
      }
    } catch (e) {
      print("Token Refresh Failed: $e");
    }
    return null;
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<void> clearSession() async {
    _accessToken = null;
    await _cookieJar.deleteAll();
  }

  // HTTP Helpers to avoid direct Dio usage in services
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }
    
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }
}
