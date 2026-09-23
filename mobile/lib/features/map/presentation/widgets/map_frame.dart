import 'package:flutter/material.dart';

import '../../../../core/theme/tena_colors.dart';
import '../../../../core/theme/tena_decorations.dart';

/// `.apple-map-frame`: rounded, bordered container the maps sit in.
class MapFrame extends StatelessWidget {
  const MapFrame({
    super.key,
    required this.child,
    required this.height,
    this.radius = TenaRadii.lg,
  });

  final Widget child;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TenaColors.mapFrame,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: TenaColors.white.withValues(alpha: 0.85)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73502C19),
            offset: Offset(0, 18),
            blurRadius: 40,
            spreadRadius: -24,
          ),
        ],
      ),
      child: child,
    );
  }
}
