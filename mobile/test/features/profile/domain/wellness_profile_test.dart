import 'package:flutter_test/flutter_test.dart';
import 'package:tenaspace/features/profile/domain/wellness_profile.dart';

void main() {
  group('WellnessProfile', () {
    const profile = WellnessProfile(
      goals: {Goal.stress, Goal.active},
      interests: {Interest.walking},
      diets: {Diet.lowSugar, Diet.none},
      mood: Mood.freshAir,
    );

    test('serialises with the wire values the API expects, in enum order', () {
      expect(profile.toJson(), {
        'goals': ['active', 'stress'],
        'interests': ['walking'],
        'diets': ['low-sugar', 'none'],
        'mood': 'fresh-air',
      });
    });

    test('round-trips through JSON', () {
      expect(WellnessProfile.fromJson(profile.toJson()), profile);
    });

    test('ignores unknown or malformed values instead of throwing', () {
      final parsed = WellnessProfile.fromJson({
        'goals': ['active', 'levitate', 42],
        'interests': 'not-a-list',
        'mood': 'ecstatic',
      });

      expect(parsed.goals, {Goal.active});
      expect(parsed.interests, isEmpty);
      expect(parsed.diets, isEmpty);
      expect(parsed.mood, isNull);
    });

    test('equality is structural and order-independent', () {
      const reordered = WellnessProfile(
        goals: {Goal.active, Goal.stress},
        interests: {Interest.walking},
        diets: {Diet.none, Diet.lowSugar},
        mood: Mood.freshAir,
      );

      expect(reordered, profile);
      expect(reordered.hashCode, profile.hashCode);
      expect(profile.copyWith(mood: Mood.calm), isNot(profile));
    });

    test('empty profile reports isEmpty and serialises null mood', () {
      expect(WellnessProfile.empty.isEmpty, isTrue);
      expect(WellnessProfile.empty.toJson()['mood'], isNull);
      expect(profile.isEmpty, isFalse);
    });

    test('copyWith can clear the mood', () {
      expect(profile.copyWith(clearMood: true).mood, isNull);
    });
  });

  group('ProfileOption enums', () {
    test('resolve from their wire value', () {
      expect(Goal.fromWire('medical'), Goal.medical);
      expect(Interest.fromWire('cafes'), Interest.cafes);
      expect(Diet.fromWire('high-protein'), Diet.highProtein);
      expect(Mood.fromWire('fresh-air'), Mood.freshAir);
      expect(Mood.fromWire('nope'), isNull);
      expect(Goal.fromWire(null), isNull);
    });
  });
}
