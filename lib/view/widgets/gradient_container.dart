import 'package:flutter/material.dart';

class GradientBorderTopBottom extends StatelessWidget {
  final Widget child;
  final Gradient topGradient;
  final Gradient bottomGradient;
  final double strokeWidth;
  final double radius;

  const GradientBorderTopBottom({
    super.key,
    required this.child,
    required this.topGradient,
    required this.bottomGradient,
    this.strokeWidth = 2,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TopBottomBorderPainter(
        topGradient: topGradient,
        bottomGradient: bottomGradient,
        strokeWidth: strokeWidth,
        radius: radius,
      ),
      child: Padding(
        padding: EdgeInsets.all(strokeWidth), // контент не лізе на бордер
        child: child,
      ),
    );
  }
}

class _TopBottomBorderPainter extends CustomPainter {
  final Gradient topGradient;
  final Gradient bottomGradient;
  final double strokeWidth;
  final double radius;

  _TopBottomBorderPainter({
    required this.topGradient,
    required this.bottomGradient,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    // -------- TOP half --------
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height / 2));

    final topPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = topGradient.createShader(rect);

    canvas.drawRRect(rrect, topPaint);
    canvas.restore();

    // -------- BOTTOM half --------
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2));

    final bottomPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = bottomGradient.createShader(rect);

    canvas.drawRRect(rrect, bottomPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TopBottomBorderPainter oldDelegate) {
    return oldDelegate.topGradient != topGradient ||
        oldDelegate.bottomGradient != bottomGradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
