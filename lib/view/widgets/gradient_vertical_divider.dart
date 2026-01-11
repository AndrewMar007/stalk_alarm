import 'package:flutter/material.dart';

class GradientVerticalDivider extends StatelessWidget {
  final Gradient gradient;
  final double thickness;
  final double? height;

  const GradientVerticalDivider({
    super.key,
    required this.gradient,
    this.thickness = 2,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: thickness,
      height: height ?? double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
      ),
    );
  }
}
