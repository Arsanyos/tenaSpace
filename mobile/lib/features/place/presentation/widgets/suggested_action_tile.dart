import 'package:flutter/material.dart';

import '../../../../core/theme/tena_colors.dart';
import '../../../../core/theme/tena_decorations.dart';
import '../../../feed/domain/suggested_action.dart';

/// One row in the "Suggested actions" card.
class SuggestedActionTile extends StatelessWidget {
  const SuggestedActionTile({
    super.key,
    required this.action,
    required this.onTap,
  });

  final SuggestedAction action;
  final VoidCallback onTap;

  static IconData iconFor(SuggestedActionType type) => switch (type) {
    SuggestedActionType.breathing => Icons.air_rounded,
    SuggestedActionType.directions => Icons.pin_drop_outlined,
    SuggestedActionType.audio => Icons.headphones_rounded,
    SuggestedActionType.save => Icons.bookmark_add_outlined,
    SuggestedActionType.timer => Icons.timer_outlined,
    SuggestedActionType.checklist => Icons.check_box_outlined,
    SuggestedActionType.call => Icons.call_rounded,
    SuggestedActionType.menu => Icons.restaurant_menu_rounded,
    SuggestedActionType.note => Icons.sticky_note_2_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TenaColors.chip,
      borderRadius: BorderRadius.circular(TenaRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TenaRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TenaRadii.md),
            border: Border.all(color: TenaColors.stone),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TenaColors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  boxShadow: TenaShadows.soft,
                ),
                child: Icon(
                  iconFor(action.type),
                  size: 17,
                  color: TenaColors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TenaColors.ink,
                      ),
                    ),
                    if (action.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        action.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: TenaColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
