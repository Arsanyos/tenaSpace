import 'package:flutter/material.dart';

import '../../../../core/theme/tena_colors.dart';
import '../../../../core/theme/tena_decorations.dart';

/// Toggle card used on every onboarding step.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? TenaColors.orangeSoft : TenaColors.white,
          borderRadius: BorderRadius.circular(TenaRadii.lg),
          border: Border.all(
            color: selected ? TenaColors.orange : TenaColors.stone,
          ),
          boxShadow: [
            ...TenaShadows.soft,
            if (selected)
              BoxShadow(
                color: TenaColors.orange.withValues(alpha: 0.15),
                spreadRadius: 2,
              ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(TenaRadii.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24, height: 1)),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: TenaColors.ink,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'SELECTED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                        color: TenaColors.orange,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
