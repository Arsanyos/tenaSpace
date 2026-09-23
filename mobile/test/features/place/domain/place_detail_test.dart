import 'package:flutter_test/flutter_test.dart';
import 'package:tenaspace/features/feed/domain/suggested_action.dart';
import 'package:tenaspace/features/feed/domain/wellness_place.dart';
import 'package:tenaspace/features/feed/domain/wellness_section.dart';
import 'package:tenaspace/features/place/domain/place_detail.dart';
import 'package:tenaspace/features/profile/domain/wellness_profile.dart';

WellnessPlace _place({
  String category = 'Café',
  List<String> tags = const [],
  double distanceKm = 2.4,
  int? durationMinutes,
  WellnessSection section = WellnessSection.eat,
  double? lat,
  double? lng,
  AudioKind? audioKind = AudioKind.none,
  List<SuggestedAction> actions = const [],
}) {
  return WellnessPlace(
    id: 'p',
    emoji: '☕',
    name: 'Place',
    category: category,
    distanceKm: distanceKm,
    recommendation: 'Because it fits.',
    section: section,
    tags: tags,
    durationMinutes: durationMinutes,
    lat: lat,
    lng: lng,
    audioKind: audioKind,
    suggestedActions: actions,
  );
}

void main() {
  group('PlaceDetail.estimateWalkingDuration', () {
    test('prefers an explicit duration', () {
      expect(
        PlaceDetail.estimateWalkingDuration(_place(durationMinutes: 12)),
        12,
      );
    });

    test('estimates from distance at 4.8 km/h for walking places', () {
      expect(
        PlaceDetail.estimateWalkingDuration(_place(category: 'Walking route')),
        30,
      );
      expect(
        PlaceDetail.estimateWalkingDuration(
          _place(tags: ['Walk'], distanceKm: 1.2),
        ),
        15,
      );
    });

    test('never goes below eight minutes', () {
      expect(
        PlaceDetail.estimateWalkingDuration(
          _place(category: 'walk', distanceKm: 0.2),
        ),
        8,
      );
    });

    test('returns null for non-walking places', () {
      expect(PlaceDetail.estimateWalkingDuration(_place()), isNull);
    });
  });

  group('PlaceDetail.fromPlace', () {
    test('derives map place, directions link and audio config', () {
      final detail = PlaceDetail.fromPlace(
        _place(
          section: WellnessSection.calm,
          lat: 9.0846,
          lng: 38.7635,
          audioKind: null,
        ),
        WellnessProfile.empty,
      );

      expect(detail.mapPlace?.lat, 9.0846);
      expect(
        detail.directionsUri.toString(),
        'https://www.google.com/maps/search/?api=1&query=9.0846%2C38.7635',
      );
      expect(detail.audioConfig?.kind, AudioKind.meditation);
    });

    test('has no map or directions without coordinates', () {
      final detail = PlaceDetail.fromPlace(_place(), WellnessProfile.empty);
      expect(detail.mapPlace, isNull);
      expect(detail.directionsUri, isNull);
    });
  });

  group('PlaceDetail actions', () {
    test('uses curated actions when present, capped at four', () {
      final actions = List.generate(
        6,
        (i) =>
            SuggestedAction(type: SuggestedActionType.note, label: 'Note $i'),
      );
      final detail = PlaceDetail.fromPlace(
        _place(actions: actions),
        WellnessProfile.empty,
      );

      expect(detail.renderedActions, hasLength(PlaceDetail.maxRenderedActions));
      expect(detail.renderedActions.first.label, 'Note 0');
    });

    test('builds section-specific defaults otherwise', () {
      final move = PlaceDetail.fromPlace(
        _place(
          section: WellnessSection.move,
          category: 'Walking route',
          lat: 9,
          lng: 38,
          audioKind: null,
        ),
        WellnessProfile.empty,
      );

      expect(move.renderedActions.map((a) => a.type), [
        SuggestedActionType.timer,
        SuggestedActionType.directions,
        SuggestedActionType.audio,
        SuggestedActionType.save,
      ]);
      expect(move.renderedActions.first.label, 'Start a 30-minute activity');

      final health = PlaceDetail.fromPlace(
        _place(section: WellnessSection.health),
        WellnessProfile.empty,
      );
      expect(health.renderedActions.map((a) => a.type), [
        SuggestedActionType.call,
        SuggestedActionType.save,
      ]);
    });
  });
}
