import 'package:flutter/material.dart';

import '../theme/tena_colors.dart';
import '../theme/tena_decorations.dart';

/// Translucent pill used on sunrise headers (`bg-white/25 text-white`).
///
/// When [filled] is true it flips to a solid white pill with ink text, which
/// is how the web renders the "Saved" state.
class GlassPillButton extends StatelessWidget {
  const GlassPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? TenaColors.ink : TenaColors.white;

    return Material(
      color: filled
          ? TenaColors.white
          : TenaColors.white.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(TenaRadii.pill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(TenaRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
