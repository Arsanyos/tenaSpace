import 'package:flutter/material.dart';

/// Circular emoji avatar used on cards, headers and map markers.
class EmojiBadge extends StatelessWidget {
  const EmojiBadge({
    super.key,
    required this.emoji,
    this.size = 64,
    this.color,
    this.gradient,
    this.border,
    this.shadows,
  });

  final String emoji;
  final double size;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        shape: BoxShape.circle,
        border: border,
        boxShadow: shadows,
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: size * 0.47, height: 1),
        textAlign: TextAlign.center,
      ),
    );
  }
}
