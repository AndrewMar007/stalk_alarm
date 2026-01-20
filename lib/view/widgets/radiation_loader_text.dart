import 'package:flutter/material.dart';

class RadiationLoaderText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration interval;

  const RadiationLoaderText({
    super.key,
    required this.text,
    this.style,
    this.interval = const Duration(milliseconds: 350),
  });

  @override
  State<RadiationLoaderText> createState() => _RadiationLoaderTextState();
}

class _RadiationLoaderTextState extends State<RadiationLoaderText> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.interval.inMilliseconds * 4),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final phase = (_c.value * 4).floor(); // 0..3
        final dots = '.' * phase;
        return Text('${widget.text}$dots', style: widget.style);
      },
    );
  }
}
