import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? color;
  final BoxBorder? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blur = 40, // Stronger blur
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // No heavy shadows, just extremely subtle depth
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // iPhone Style: Very low opacity tint
              color: color ?? (isDark 
                  ? Colors.black.withOpacity(0.2) 
                  : Colors.white.withOpacity(0.3)
              ), 
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                // Subtle border highlight (always white-ish for glass effect)
                color: isDark 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.white.withOpacity(0.2), 
                width: 1, // Keep it thin
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
