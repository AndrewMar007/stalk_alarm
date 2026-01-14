import 'package:flutter/material.dart';

class GradientBorderButton extends StatelessWidget {
  final Widget child;
  final Gradient topGradient;
  final Gradient bottomGradient;
  final double strokeWidth;
  final double radius;
  final VoidCallback? onTap;

  const GradientBorderButton({
    super.key,
    required this.child,
    required this.topGradient,
    required this.bottomGradient,
    this.strokeWidth = 2,
    this.radius = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias, // 🔥 КЛЮЧОВЕ
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        splashFactory: InkRipple.splashFactory,
        splashColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.12),
        hoverColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.08),
        highlightColor: Colors.transparent,
        child: CustomPaint(
          painter: _TopBottomBorderPainter(
            topGradient: topGradient,
            bottomGradient: bottomGradient,
            strokeWidth: strokeWidth,
            radius: radius,
          ),
          child: Padding(
            padding: EdgeInsets.all(strokeWidth),
            child: child,
          ),
        ),
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

    // -------- TOP --------
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height / 2));

    final topPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = topGradient.createShader(rect);

    canvas.drawRRect(rrect, topPaint);
    canvas.restore();

    // -------- BOTTOM --------
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
    );

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
