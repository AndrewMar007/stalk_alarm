import 'package:flutter/material.dart';

class RadiationLoader extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color color;

  const RadiationLoader({
    super.key,
    this.size = 64,
    this.duration = const Duration(seconds: 1),
    this.color = Colors.white, // ⬅️ колір
  });

  @override
  State<RadiationLoader> createState() => _RadiationLoaderState();
}

class _RadiationLoaderState extends State<RadiationLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'assets/radiation_loader.png',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        color: widget.color,
        colorBlendMode: BlendMode.srcIn, // ⬅️ ГОЛОВНЕ
      ),
    );
  }
}
