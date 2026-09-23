import 'package:flutter/material.dart';

import '../theme/tena_colors.dart';
import '../theme/tena_decorations.dart';
import '../theme/tena_text.dart';

/// `rounded-full bg-chip px-3 py-1 text-xs font-bold text-clay`
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: TenaColors.chip,
        borderRadius: BorderRadius.circular(TenaRadii.pill),
      ),
      child: Text(label, style: TenaText.tag),
    );
  }
}
