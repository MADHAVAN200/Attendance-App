import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DashedContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  const DashedContainer({
    super.key,
    required this.child,
    this.color = const Color(0xFFE2E8F0),
    this.strokeWidth = 2.0,
    this.gap = 5.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedRectPainter(
        color: color, 
        strokeWidth: strokeWidth, 
        gap: gap,
        radius: borderRadius
      ),
      child: Padding(
        padding: const EdgeInsets.all(2), // Optional inner padding
        child: child,
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.gap = 5.0,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    _drawDashedRoundRect(canvas, paint, size);
  }

  void _drawDashedRoundRect(Canvas canvas, Paint paint, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height), 
      Radius.circular(radius)
    );
    
    final Path path = Path()..addRRect(rrect);
    
    // Manual Dash implementation or use PathMetric
    final ui.PathMetrics pathMetrics = path.computeMetrics();
    
    for (ui.PathMetric metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = 5.0; // Dash length
        final double spacing = gap; // Gap length
        
        canvas.drawPath(
          metric.extractPath(distance, distance + length),
          paint,
        );
        distance += length + spacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
