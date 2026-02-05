import 'package:flutter/material.dart';
import '../../login_screen.dart';
import '../../views/forgot_password/forgot_password_screen.dart';

class LoginMobilePortrait extends StatelessWidget {
  final LoginScreenState controller;

  const LoginMobilePortrait({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Image.asset(
                'assets/mano.png',
                height: 80,
                width: 80,
              ),
              const SizedBox(height: 24),

              // Welcome Back Text
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue to MANO Attendance',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),

              Card(
                elevation: 4,
                color: isDark ? const Color(0xFF1E2939) : Colors.white,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                // Use Clip.none so the ReCaptcha popup can overflow the card bounds
                clipBehavior: Clip.none,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email or Mobile Identifier
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email or Phone', 
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87
                              )
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.identifierController,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Mano',
                                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF101828) : const Color(0xFFF0F4FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.mail_outline, color: isDark ? Colors.white54 : Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Password
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Password', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87
                                  )
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: Color(0xFF4F46E5), 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controller.passwordController,
                              obscureText: !controller.isPasswordVisible,
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              decoration: InputDecoration(
                                hintText: '••••••',
                                hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38, letterSpacing: 2),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF101828) : const Color(0xFFF0F4FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white54 : Colors.grey),
                                suffixIcon: IconButton(
                                  icon: Icon(controller.isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off, color: isDark ? Colors.white54 : Colors.grey),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                        
                        // Captcha
                        const SizedBox(height: 24),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 304),
                            child: controller.buildCaptcha(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login Button
                        ElevatedButton(
                          onPressed: (controller.isLoading ||
                                  controller.captchaValue == null)
                              ? null
                              : controller.handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: controller.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Sign in',
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
