import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/recaptcha_v2.dart';
import '../../login_screen.dart';

class LoginTabletPortrait extends StatelessWidget {
  final LoginScreenState controller;

  const LoginTabletPortrait({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFF0F4F8), const Color(0xFFE2E8F0)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               // Branding (Top of Portrait)
                Image.asset(
                'assets/Attendance Logo.png',
                height: 100,
              ),
              const SizedBox(height: 16),
              if (isDark)
              Text(
                'MANO',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),

              // Login Card
              const SizedBox(height: 32),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
               Text(
                'Sign in to your admin account',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 48),

              // Login Card
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500), // Slightly wider than mobile
                child: GlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        // Internal text removed
                        
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
                          const SizedBox(height: 24),
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
                          height: 56,
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
                                : Text('Sign In', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
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
