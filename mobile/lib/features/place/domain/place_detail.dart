import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../feed/domain/suggested_action.dart';
import '../../feed/domain/wellness_place.dart';
import '../../feed/domain/wellness_section.dart';
import '../../map/domain/map_place.dart';
import '../../profile/domain/wellness_profile.dart';
import 'audio_config.dart';

/// Everything the detail screen needs, derived once from a curated place and
/// the user's profile (port of `lib/get-place-detail.ts`).
@immutable
final class PlaceDetail {
  const PlaceDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.section,
    required this.distanceKm,
    required this.tags,
    required this.whyRecommended,
    required this.durationMinutes,
    required this.bestTime,
    required this.mapPlace,
    required this.audioConfig,
    required this.suggestedActions,
  });

  factory PlaceDetail.fromPlace(WellnessPlace place, WellnessProfile profile) {
    return PlaceDetail(
      id: place.id,
      name: place.name,
      category: place.category,
      emoji: place.emoji,
      section: place.section,
      distanceKm: place.distanceKm,
      tags: place.tags,
      whyRecommended: place.recommendation,
      durationMinutes: estimateWalkingDuration(place),
      bestTime: place.bestTime,
      mapPlace: MapPlace.fromPlace(place),
      audioConfig: resolveAudioConfig(place, profile),
      suggestedActions: place.suggestedActions,
    );
  }

  static const maxRenderedActions = 4;

  /// Average easy wellness-walk pace used to estimate durations.
  static const walkingPaceKmPerHour = 4.8;

  final String id;
  final String name;
  final String category;
  final String emoji;
  final WellnessSection section;
  final double distanceKm;
  final List<String> tags;
  final String whyRecommended;
  final int? durationMinutes;
  final String? bestTime;
  final MapPlace? mapPlace;
  final ResolvedAudioConfig? audioConfig;
  final List<SuggestedAction> suggestedActions;

  String get distanceLabel => WellnessPlace.formatDistance(distanceKm);

  Uri? get directionsUri {
    final place = mapPlace;
    if (place == null) return null;
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${place.lat},${place.lng}',
    });
  }

  /// Groq's actions when present, otherwise sensible defaults — capped at four
  /// so the card never grows past what fits comfortably on a phone.
  List<SuggestedAction> get renderedActions {
    final actions = suggestedActions.isNotEmpty
        ? suggestedActions
        : defaultActions;
    return actions.take(maxRenderedActions).toList();
  }

  /// Port of `getDefaultActions`.
  List<SuggestedAction> get defaultActions {
    final actions = <SuggestedAction>[];

    switch (section) {
      case WellnessSection.move:
        actions.add(
          SuggestedAction(
            type: SuggestedActionType.timer,
            label: durationMinutes != null
                ? 'Start a $durationMinutes-minute activity'
                : 'Start a short movement session',
            description: 'Use this place as your next gentle movement stop.',
          ),
        );
      case WellnessSection.calm:
        actions.add(
          const SuggestedAction(
            type: SuggestedActionType.breathing,
            label: 'Start a grounding pause',
            description: 'Take a few slow breaths before or after you arrive.',
          ),
        );
      case WellnessSection.eat:
        actions.add(
          const SuggestedAction(
            type: SuggestedActionType.menu,
            label: 'Review healthy order ideas',
            description: 'Pick options that match your food preferences.',
          ),
        );
      case WellnessSection.health:
        actions.add(
          const SuggestedAction(
            type: SuggestedActionType.call,
            label: 'Call before visiting',
            description: 'Confirm opening hours and available services.',
          ),
        );
    }

    if (mapPlace != null) {
      actions.add(
        const SuggestedAction(
          type: SuggestedActionType.directions,
          label: 'Get directions',
          description: 'Open this location in Google Maps.',
        ),
      );
    }

    final audio = audioConfig;
    if (audio != null) {
      actions.add(
        SuggestedAction(
          type: SuggestedActionType.audio,
          label: audio.label,
          description: 'Use background sound while you read or unwind.',
        ),
      );
    }

    actions.add(
      const SuggestedAction(
        type: SuggestedActionType.save,
        label: 'Save this place',
        description: 'Keep it in your wellness list for later.',
      ),
    );

    return actions;
  }

  /// Explicit duration wins; otherwise walking places get an estimate from
  /// their distance (minimum 8 minutes). Non-walking places return `null`.
  static int? estimateWalkingDuration(WellnessPlace place) {
    if (place.durationMinutes != null) return place.durationMinutes;

    final isWalkingPlace =
        place.category.toLowerCase().contains('walk') ||
        place.tags.any((tag) => tag.toLowerCase().contains('walk'));
    if (!isWalkingPlace) return null;

    final minutes = (place.distanceKm / walkingPaceKmPerHour * 60).round();
    return math.max(8, minutes);
  }
}
