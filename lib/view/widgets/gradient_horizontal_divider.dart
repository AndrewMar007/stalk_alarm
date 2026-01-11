
import 'package:flutter/material.dart';

class GradientDivider extends StatelessWidget {
  final Gradient gradient;
  final double thickness;
  final double? width;

  const GradientDivider({
    super.key,
    required this.gradient,
    this.thickness = 2,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: thickness,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
      ),
    );
  }
}
