import 'package:flutter_test/flutter_test.dart';
import 'package:tenaspace/features/feed/domain/suggested_action.dart';
import 'package:tenaspace/features/feed/domain/wellness_feed.dart';
import 'package:tenaspace/features/feed/domain/wellness_place.dart';
import 'package:tenaspace/features/feed/domain/wellness_section.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('WellnessFeed.fromJson', () {
    final feed = WellnessFeed.fromJson(curatedFeedJson)!;

    test('parses the featured place with its valid actions only', () {
      expect(feed.featured.id, 'meskel-walk');
      expect(feed.featured.durationMinutes, 25);
      expect(feed.featured.suggestedActions.map((a) => a.type), [
        SuggestedActionType.timer,
        SuggestedActionType.directions,
      ]);
      expect(feed.featured.suggestedActions[1].description, 'Open maps');
    });

    test('always emits the four sections in canonical order', () {
      expect(feed.sections.map((s) => s.section), WellnessSection.values);
    });

    test('drops invalid places, caps at three and de-duplicates ids', () {
      final move = feed.sections.first;
      expect(move.title, 'Get moving');
      expect(move.places.map((p) => p.id), [
        'bole-court',
        'bole-court-2',
        'jan-meda-running-track',
      ]);
    });

    test('falls back to the default title when missing or blank', () {
      expect(feed.sections[1].title, WellnessSection.eat.defaultTitle);
      expect(feed.sections[3].title, WellnessSection.health.defaultTitle);
    });

    test('unknown section ids are skipped and missing ones are empty', () {
      final calm = feed.sections[2];
      expect(calm.section, WellnessSection.calm);
      expect(calm.places, isEmpty);
      expect(feed.allPlaces.any((p) => p.id == 'ignored'), isFalse);
    });

    test('coerces numbers and trims tags', () {
      final court = feed.sections.first.places.first;
      expect(court.distanceKm, 2.0);
      expect(court.distanceLabel, '2');
      expect(court.tags, hasLength(WellnessPlace.maxTags));
      expect(court.audioKind, AudioKind.ambient);
      expect(court.hasCoordinates, isFalse);
    });

    test('returns null for payloads without a featured place', () {
      expect(WellnessFeed.fromJson({'sections': []}), isNull);
      expect(WellnessFeed.fromJson('nonsense'), isNull);
    });

    test('findPlace and allPlaces cover featured + sections', () {
      expect(feed.findPlace('green-bowl')?.name, 'Green Bowl');
      expect(feed.findPlace('nope'), isNull);
      expect(feed.allPlaces.first.id, 'meskel-walk');
      expect(
        feed.allPlaces.map((p) => p.id).toSet().length,
        feed.allPlaces.length,
      );
      expect(feed.hasPlaces, isTrue);
    });

    test('survives a JSON round-trip (used by the on-disk cache)', () {
      final restored = WellnessFeed.fromJson(feed.toJson());
      expect(restored, feed);
    });
  });

  group('WellnessPlace helpers', () {
    test('slugify mirrors the server implementation', () {
      expect(
        WellnessPlace.slugify('  Jan Meda Running Track! '),
        'jan-meda-running-track',
      );
      expect(WellnessPlace.slugify('Ghión Garden'), 'ghi-n-garden');
      expect(WellnessPlace.slugify('a' * 80).length, 64);
    });

    test('formatDistance prints like JavaScript', () {
      expect(WellnessPlace.formatDistance(1.8), '1.8');
      expect(WellnessPlace.formatDistance(2), '2');
      expect(WellnessPlace.formatDistance(3.14), '3.1');
    });
  });
}
