import 'dart:math' as math;
import 'package:flutter/material.dart';

class VoltmeterGauge extends StatefulWidget {
  final double value; // 0..100
  final double size;
  final String? label;
  final Duration duration;

  const VoltmeterGauge({
    super.key,
    required this.value,
    this.size = 220,
    this.label,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<VoltmeterGauge> createState() => _VoltmeterGaugeState();
}

class _VoltmeterGaugeState extends State<VoltmeterGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();

    final safeValue = widget.value.clamp(0, 100).toDouble();
    _oldValue = 0;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: _oldValue,
      end: safeValue,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
    _oldValue = safeValue;
  }

  @override
  void didUpdateWidget(covariant VoltmeterGauge oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newValue = widget.value.clamp(0, 100).toDouble();
    final oldSafeValue = _oldValue;

    if (oldSafeValue != newValue || oldWidget.duration != widget.duration) {
      if (oldWidget.duration != widget.duration) {
        _controller.duration = widget.duration;
      }

      _animation = Tween<double>(
        begin: oldSafeValue,
        end: newValue,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _controller
        ..reset()
        ..forward();

      _oldValue = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _progressColor(double value) {
    const green = Color(0xFF41C95B);
    const orange = Color.fromARGB(255, 248, 137, 41);
    const red = Color(0xFFE53935);

    final v = value.clamp(0, 100).toDouble();

    if (v <= 30) {
      return green;
    }
    if (v <= 60) {
      final t = (v - 30.0) / 35.0;
      return Color.lerp(green, orange, t) ?? orange;
    }

    final t = (v - 60.0) / 35.0;
    return Color.lerp(orange, red, t) ?? red;
  }

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    const accent = Color.fromARGB(255, 248, 137, 41);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final gaugeSize =
            maxW.isFinite ? math.min(widget.size, maxW * 0.6) : widget.size;
        final isSmall = gaugeSize < 200;

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            final animatedValue = _animation.value.clamp(0, 100).toDouble();
            final shownPercent = animatedValue.round();
            final progressColor = _progressColor(animatedValue);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEn
                      ? 'Emission probability in the region'
                      : 'Ймовірність викиду в області',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accent,
                    fontSize: isSmall ? 16 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: isSmall ? 10 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.label ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 252, 151, 62),
                          fontSize: isSmall ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: gaugeSize,
                      height: gaugeSize * 0.72,
                      child: CustomPaint(
                        painter: _VoltmeterGaugePainter(
                          value: animatedValue,
                          isSmall: isSmall,
                          progressColor: progressColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '$shownPercent%',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: accent,
                          fontSize: isSmall ? 26 : 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _VoltmeterGaugePainter extends CustomPainter {
  final double value;
  final bool isSmall;
  final Color progressColor;

  _VoltmeterGaugePainter({
    required this.value,
    required this.isSmall,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const accent = Color.fromARGB(255, 248, 137, 41);

    final center = Offset(size.width / 2, size.height * 0.9);
    final radius = math.min(size.width / 2, size.height) - 8;

    const startAngle = math.pi;
    const sweepAngle = math.pi;

    final baseStroke = isSmall ? 10.0 : 14.0;
    final tickStroke = isSmall ? 2.0 : 2.5;
    final majorTickStroke = isSmall ? 3.0 : 3.5;

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final bgArcPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseStroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, bgArcPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseStroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      startAngle,
      sweepAngle * (value / 100),
      false,
      progressPaint,
    );

    for (int i = 0; i <= 20; i++) {
      final t = i / 20;
      final angle = startAngle + sweepAngle * t;

      final isMajor = i % 5 == 0;
      final outerR = radius + (isMajor ? 2 : 0);
      final innerR = radius - (isMajor ? 18 : 10);

      final p1 = Offset(
        center.dx + math.cos(angle) * outerR,
        center.dy + math.sin(angle) * outerR,
      );
      final p2 = Offset(
        center.dx + math.cos(angle) * innerR,
        center.dy + math.sin(angle) * innerR,
      );

      final tickPaint = Paint()
        ..color = isMajor
            ? accent.withOpacity(0.9)
            : Colors.white.withOpacity(0.25)
        ..strokeWidth = isMajor ? majorTickStroke : tickStroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, tickPaint);
    }

    _drawText(
      canvas,
      '0%',
      Offset(center.dx - radius - 20, center.dy - 10),
      isSmall,
    );
    _drawText(
      canvas,
      '50%',
      Offset(center.dx, center.dy - radius - 20),
      isSmall,
    );
    _drawText(
      canvas,
      '100%',
      Offset(center.dx + radius + 23, center.dy - 10),
      isSmall,
    );

    final needleAngle = startAngle + sweepAngle * (value / 100);
    final needleLength = radius - 28;

    final needleEnd = Offset(
      center.dx + math.cos(needleAngle) * needleLength,
      center.dy + math.sin(needleAngle) * needleLength,
    );

    final needlePaint = Paint()
      ..color = progressColor
      ..strokeWidth = isSmall ? 3 : 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    canvas.drawCircle(
      center,
      isSmall ? 8 : 10,
      Paint()..color = const Color(0xFF111417),
    );

    canvas.drawCircle(
      center,
      isSmall ? 5 : 6,
      Paint()..color = accent,
    );
  }

  void _drawText(Canvas canvas, String text, Offset center, bool isSmall) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white70,
          fontSize: isSmall ? 12 : 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _VoltmeterGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.isSmall != isSmall ||
        oldDelegate.progressColor != progressColor;
  }
}