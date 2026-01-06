import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/constants/api_constants.dart';
import '../dashboard/dashboard_screen.dart';
import 'mobile/views/login_mobile_portrait.dart';
import 'tablet/views/login_tablet_portrait.dart';
import 'tablet/views/login_tablet_landscape.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  bool isLoading = false;
  bool isPasswordVisible = false;

  String? captchaToken;

  @override
  void initState() {
    super.initState();
    // ReCaptcha V2 is handled by the widget in the view
  }
  
  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void setCaptchaToken(String token) {
    setState(() {
      captchaToken = token;
    });
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    if (captchaToken == null) {
       _showError('Please complete the Captcha verification.');
       return;
    }

    setState(() => isLoading = true);

    try {
      if (!mounted) return;
      final authService = Provider.of<AuthService>(context, listen: false);
      
      await authService.login(
        emailController.text.trim(),
        passwordController.text,
        captchaToken!,
      );

      if (mounted) {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (_) => const DashboardScreen()),
         );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
        // Reset (Optional: technically we might want to reload the webview, but for now user can just re-click if needed or we assume token is single-use)
        setState(() => captchaToken = null); 
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force Immersive Mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Mobile Breakpoint
          if (constraints.maxWidth < 600) {
            return LoginMobilePortrait(controller: this);
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return LoginTabletPortrait(controller: this);
              } else {
                // Check if it's a small landscape screen (like mobile landscape) or tablet
                if (constraints.maxWidth < 900) {
                   // Fallback to mobile portrait style for small landscape or implement MobileLandscape if needed
                   // For now, reusing MobilePortrait usually works well enough or TabletPortrait
                   return LoginMobilePortrait(controller: this); 
                }
                return LoginTabletLandscape(controller: this);
              }
            },
          );
        },
      ),
    );
  }
}
