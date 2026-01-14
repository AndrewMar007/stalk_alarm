import 'package:flutter/material.dart';

class VerticalLineTickMarkShape extends SliderTickMarkShape {
  final double height;
  final double width;

  const VerticalLineTickMarkShape({
    this.height = 10,
    this.width = 2,
  });

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    bool? isEnabled,
  }) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool? isEnabled,
  }) {
    final Canvas canvas = context.canvas;

    final bool isActive = (textDirection == TextDirection.ltr)
        ? center.dx <= thumbCenter.dx
        : center.dx >= thumbCenter.dx;

    final Paint paint = Paint()
      ..color = isActive
          ? sliderTheme.activeTickMarkColor!
          : sliderTheme.inactiveTickMarkColor!
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx, center.dy - height / 2),
      Offset(center.dx, center.dy + height / 2),
      paint,
    );
  }
}
