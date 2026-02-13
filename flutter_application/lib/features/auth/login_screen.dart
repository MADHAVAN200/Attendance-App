import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // Added geolocator

import 'word_captcha.dart'; // Import WordCaptcha
import 'mobile/views/login_mobile_portrait.dart';
import 'tablet/views/login_tablet_portrait.dart';
import 'tablet/views/login_tablet_landscape.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/widgets/custom_dialog.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }
  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  
  // New Captcha State
  String? captchaId;
  String? captchaValue;

  void togglePasswordVisibility() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void onCaptchaChanged(String? id, String? value) {
    final bool wasValid = captchaValue != null && captchaValue!.isNotEmpty;
    final bool isValid = value != null && value.isNotEmpty;
    
    // Always update the values
    captchaId = id;
    captchaValue = value;

    // Only rebuild if the validity state changes (which affects the Login button)
    if (wasValid != isValid) {
      setState(() {});
    }
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    if (captchaId == null || captchaValue == null || captchaValue!.isEmpty) {
      _showError('Please complete CAPTCHA verification');
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.login(
        identifierController.text.trim(),
        passwordController.text,
        captchaId!,
        captchaValue!,
      );

      if (!mounted) return;
      // Removed manual Navigator.pushReplacement. 
      // AuthWrapper in main.dart handles the transition reactively.
    } catch (e) {
      _showError(e.toString());
      // Refresh captcha on error? Ideally yes, but WordCaptcha handles its own refresh.
      // We might want to force refresh it, but for now user can tap refresh.
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    String title = "Login Error";
    IconData icon = Icons.error_outline;
    Color iconColor = Colors.red;

    final lowerMsg = msg.toLowerCase();
    if (lowerMsg.contains("captcha") || lowerMsg.contains("verification")) {
      title = "Verification Required";
      icon = Icons.security_rounded;
      iconColor = Colors.orange;
    } else if (lowerMsg.contains("invalid") || lowerMsg.contains("credential") || lowerMsg.contains("password") || lowerMsg.contains("username")) {
      title = "Invalid Credentials";
      icon = Icons.lock_person_rounded;
      iconColor = Colors.red;
    } else if (lowerMsg.contains("connection") || lowerMsg.contains("network") || lowerMsg.contains("timeout")) {
      title = "Connection Error";
      icon = Icons.wifi_off_rounded;
      iconColor = Colors.blue;
    }

    CustomDialog.show(
      context: context,
      title: title,
      message: msg,
      icon: icon,
      iconColor: iconColor,
      positiveButtonText: "Try Again",
      onPositivePressed: () {},
    );
  }

  Widget buildCaptcha() {
    return WordCaptcha(
      onCaptchaChanged: onCaptchaChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return LoginMobilePortrait(controller: this);
          }
          return OrientationBuilder(
            builder: (_, orientation) {
              return orientation == Orientation.portrait
                  ? LoginTabletPortrait(controller: this)
                  : LoginTabletLandscape(controller: this);
            },
          );
        },
      ),
    );
  }
}
