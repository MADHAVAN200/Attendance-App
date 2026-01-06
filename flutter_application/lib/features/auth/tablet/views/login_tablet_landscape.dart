import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/recaptcha_v2.dart';
import '../../login_screen.dart';

class LoginTabletLandscape extends StatelessWidget {
  final LoginScreenState controller;

  const LoginTabletLandscape({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFF0F4F8), const Color(0xFFE2E8F0)],
        ),
      ),
      child: Row(
        children: [
          // Left Side: Branding / Illustration
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Image.asset(
                    'assets/Attendance Logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  if (isDark)
                  Text(
                    'MANO',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                   if (isDark)
                   Text(
                    'Project Consultants',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400],
                    ),
                  ),
                  if (isDark)
                  const SizedBox(height: 32),
                  if (isDark)
                  Text(
                    'Manage your workforce efficiently with our advanced attendance and tracking system.',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      height: 1.5,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right Side: Login Form
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: GlassContainer(
                  width: 450, // Fixed width for cleaner look
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please sign in to continue',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 40),

                          TextFormField(
                            controller: controller.emailController,
                            style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface),
                            decoration: InputDecoration(
                              labelText: 'Email or Phone',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              final isEmail = value.contains('@');
                              final isPhone = RegExp(r'^[0-9+]+$').hasMatch(value);
                              if (!isEmail && !isPhone) return 'Enter a valid email or phone number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: controller.passwordController,
                            obscureText: !controller.isPasswordVisible,
                            style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(controller.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your password';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          Center(
                            child: ReCaptchaV2(
                              onVerified: controller.setCaptchaToken,
                            ),
                          ),

                          const SizedBox(height: 24),

                           SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading ? null : controller.handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: controller.isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Sign In', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
