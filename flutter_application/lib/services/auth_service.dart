import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../shared/models/user_model.dart';
import 'api_client.dart';
import '../shared/constants/api_constants.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  User? _currentUser;
  bool _isLoading = false;

  User? get user => _currentUser;
  bool get isAuthenticated => _client.accessToken != null;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await _client.init();
    // Try to restore session
    // ApiClient cookie jar handles the token persistence mostly?
    // The old service used cookie jar. 
    // We can also try to fetch "Me" to see if session is valid.
    await checkAuthStatus();
  }

  Future<Map<String, dynamic>> login(String userInput, String password, String captchaId, String captchaText) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _client.post(ApiConstants.login, data: {
        'user_input': userInput,
        'user_password': password,
        'captchaId': captchaId,
        'captchaText': captchaText,
      });

      if (response.statusCode == 200) {
        final token = response.data['accessToken'];
        _client.setAccessToken(token); // In-memory update
        
        // Fetch user
        await getMe();
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Login Failed');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {}
    await _client.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  Future<User?> getMe() async {
    try {
      final response = await _client.get(ApiConstants.me);
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      print("GetMe Failed: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> checkAuthStatus() async {
    // Rely on ApiClient's cookie to refresh token implicitly via generic request or explicit refresh
    // The old logic called refreshToken() explicitly. 
    // Let's call getMe() directly. If 401, Interceptor will try refresh.
    // If that fails, getMe returns null.
    final user = await getMe();
    if (user != null) {
      return {'user': user};
    }
    return null;
  }
  
  // Captcha
  Future<Map<String, dynamic>> fetchCaptcha() async {
     try {
       final response = await _client.get(ApiConstants.captchaGenerate);
       return response.data;
     } catch (e) {
       throw Exception("Failed to load captcha");
     }
  }
}
