import 'package:flutter/material.dart';

import '../../../../core/theme/tena_colors.dart';
import '../../../../core/theme/tena_decorations.dart';

/// Decorative rotated pill on the splash screen ("🏀 Basketball Court").
class FloatingPill extends StatelessWidget {
  const FloatingPill({
    super.key,
    required this.emoji,
    required this.title,
    required this.text,
    this.rotationDegrees = 0,
  });

  final String emoji;
  final String title;
  final String text;
  final double rotationDegrees;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Transform.rotate(
        angle: rotationDegrees * 3.141592653589793 / 180,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: TenaColors.white,
            borderRadius: BorderRadius.circular(TenaRadii.pill),
            boxShadow: TenaShadows.lift,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24, height: 1)),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: TenaColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TenaColors.muted,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
