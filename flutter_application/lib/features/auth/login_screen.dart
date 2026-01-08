import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 're_captcha_v2.dart';
import 'mobile/views/login_mobile_portrait.dart';
import 'tablet/views/login_tablet_portrait.dart';
import 'tablet/views/login_tablet_landscape.dart';
import '../../shared/services/auth_service.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  String? captchaToken;

  void togglePasswordVisibility() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void setCaptchaToken(String token) {
    setState(() => captchaToken = token);
  }

  Future<void> handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    if (captchaToken == null) {
      _showError('Please complete CAPTCHA verification');
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      // Determine if input looks like an email for tracking, 
      // but send as 'user_input' to backend regardless
      await auth.login(
        identifierController.text.trim(),
        passwordController.text,
        captchaToken!,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AttendanceApp()),
      );
    } catch (e) {
      _showError(e.toString());
      setState(() => captchaToken = null);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Widget buildCaptcha() {
    // Pass current theme brightness to customize ReCaptcha appearance if desired
    return ReCaptchaV2(
      siteKey: dotenv.env['RECAPTCHA_SITE_KEY'] ?? 'missing-key',
      onVerified: setCaptchaToken,
    );
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
