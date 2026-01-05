import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GradientBorderCupertinoTabBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const GradientBorderCupertinoTabBar({
    required this.items,
    required this.onTap,
    required this.height,
    required this.backgroundColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.borderWidth,
    required this.topGradient,
    required this.bottomGradient,
  });

  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;
  final double height;

  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;

  final double borderWidth;
  final Gradient topGradient;
  final Gradient bottomGradient;

  @override
  Size get preferredSize => Size.fromHeight(height);

  // ✅ важливо для iOS: каже що таббар "закриває" контент за собою
  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // сам таббар
        Positioned.fill(
          child: CupertinoTabBar(
            items: items,
            onTap: onTap,
            height: height,
            backgroundColor: backgroundColor,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            // ❌ вимикаємо стандартний бордер
            border: const Border(top: BorderSide(color: Colors.transparent, width: 0)),
          ),
        ),

        // ✅ TOP градієнтна лінія
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: borderWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: topGradient),
          ),
        ),

        // ✅ BOTTOM градієнтна лінія
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: borderWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: bottomGradient),
          ),
        ),
      ],
    );
  }
}
