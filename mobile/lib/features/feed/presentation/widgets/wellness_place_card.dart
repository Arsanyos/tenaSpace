import 'package:flutter/material.dart';

import '../../../../core/theme/tena_colors.dart';
import '../../../../core/theme/tena_decorations.dart';
import '../../../../core/theme/tena_text.dart';
import '../../../../core/widgets/emoji_badge.dart';
import '../../../../core/widgets/tag_chip.dart';
import '../../domain/wellness_place.dart';

enum WellnessPlaceCardVariant { standard, featured }

/// Feed card. The featured variant swaps the emoji badge for the sunrise
/// gradient and adds the "Today's wellness match" eyebrow.
class WellnessPlaceCard extends StatelessWidget {
  const WellnessPlaceCard({
    super.key,
    required this.place,
    this.variant = WellnessPlaceCardVariant.standard,
    this.onViewDetails,
  });

  final WellnessPlace place;
  final WellnessPlaceCardVariant variant;
  final VoidCallback? onViewDetails;

  bool get _isFeatured => variant == WellnessPlaceCardVariant.featured;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onViewDetails != null,
      label: '${place.name}, ${place.category}, ${place.distanceLabel} km away',
      child: Material(
        color: TenaColors.white,
        borderRadius: BorderRadius.circular(TenaRadii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onViewDetails,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TenaRadii.card),
              border: Border.all(color: TenaColors.stone),
              boxShadow: TenaShadows.lift,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isFeatured) ...[
                    const Text(
                      "✨ TODAY'S WELLNESS MATCH",
                      style: TenaText.eyebrow,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiBadge(
                        emoji: place.emoji,
                        size: 64,
                        color: TenaColors.orangeSoft,
                        gradient: _isFeatured ? TenaGradients.sunrise : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: TextStyle(
                                fontSize: _isFeatured ? 20 : 18,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                                color: TenaColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${place.category} · ${place.distanceLabel} km away',
                              style: TenaText.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    place.recommendation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      color: TenaColors.sage,
                    ),
                  ),
                  if (!_isFeatured && place.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final tag in place.tags) TagChip(tag)],
                    ),
                  ],
                  if (onViewDetails != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _isFeatured ? 'Open match details →' : 'View Details →',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
