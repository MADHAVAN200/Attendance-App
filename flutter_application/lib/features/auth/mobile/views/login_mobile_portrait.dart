import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/recaptcha_v2.dart';
import '../../login_screen.dart';

class LoginMobilePortrait extends StatelessWidget {
  final LoginScreenState controller;

  const LoginMobilePortrait({
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
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset(
                'assets/Attendance Logo.png',
                height: 80,
              ),
              const SizedBox(height: 16),
              if (isDark) // Only show text if dark mode, or remove completely if logo has text
              Text(
                'MANO',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
               if (isDark)
               Text(
                'Project Consultants',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 48),

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
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Removed internal Welcome text
                        
                        TextFormField(
                          controller: controller.emailController,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email or Phone',
                            labelStyle: const TextStyle(fontSize: 14),
                            prefixIcon: const Icon(Icons.person_outline, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            // Simple check: Contains @ for email, OR is digits for phone
                            final isEmail = value.contains('@');
                            // Allow any length phone number (digits and +)
                            final isPhone = RegExp(r'^[0-9+]+$').hasMatch(value);
                            
                            if (!isEmail && !isPhone) {
                               return 'Enter a valid email or phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible,
                          style: GoogleFonts.inter(
                             fontSize: 14,
                             color: Theme.of(context).colorScheme.onSurface
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                             labelStyle: const TextStyle(fontSize: 14),
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(controller.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
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
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (controller.isLoading || controller.captchaToken == null) ? null : controller.handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: controller.isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('Sign In', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
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
