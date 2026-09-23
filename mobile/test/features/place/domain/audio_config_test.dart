import 'package:flutter_test/flutter_test.dart';
import 'package:tenaspace/features/feed/domain/wellness_place.dart';
import 'package:tenaspace/features/feed/domain/wellness_section.dart';
import 'package:tenaspace/features/place/domain/audio_config.dart';
import 'package:tenaspace/features/profile/domain/wellness_profile.dart';

WellnessPlace _place({
  String id = 'some-place',
  WellnessSection section = WellnessSection.calm,
  AudioKind? audioKind,
}) {
  return WellnessPlace(
    id: id,
    emoji: '🧘',
    name: 'Place',
    category: 'Category',
    distanceKm: 1,
    recommendation: 'Because.',
    section: section,
    audioKind: audioKind,
  );
}

void main() {
  const noMood = WellnessProfile.empty;

  group('resolveAudioConfig', () {
    test('audioKind none disables audio regardless of section', () {
      expect(
        resolveAudioConfig(
          _place(section: WellnessSection.calm, audioKind: AudioKind.none),
          noMood,
        ),
        isNull,
      );
    });

    test('eat and health sections have no default audio', () {
      expect(
        resolveAudioConfig(_place(section: WellnessSection.eat), noMood),
        isNull,
      );
      expect(
        resolveAudioConfig(_place(section: WellnessSection.health), noMood),
        isNull,
      );
    });

    test('calm places stream the bundled meditation track by default', () {
      final config = resolveAudioConfig(_place(), noMood)!;
      expect(config.kind, AudioKind.meditation);
      expect(config.isStatic, isTrue);
      expect(config.staticPath, '/audio/calm-meditation.mp3');
      expect(config.label, 'Play calm background sound');
    });

    test('move places generate an AI walking mix', () {
      final config = resolveAudioConfig(
        _place(section: WellnessSection.move),
        noMood,
      )!;
      expect(config.kind, AudioKind.walkingMix);
      expect(config.isStatic, isFalse);
      expect(config.durationSeconds, 35);
    });

    test('hand-tuned per-place configs win when Groq sends no audioKind', () {
      final config = resolveAudioConfig(_place(id: 'entoto-view'), noMood)!;
      expect(config.staticPath, '/audio/entoto-meditation.mp3');
      expect(config.durationSeconds, 50);
    });

    test('an explicit audioKind falls back to the section default instead', () {
      final config = resolveAudioConfig(
        _place(id: 'entoto-view', audioKind: AudioKind.meditation),
        noMood,
      )!;
      expect(config.staticPath, '/audio/calm-meditation.mp3');
    });
  });

  group('buildAudioPrompt', () {
    test('appends the mood hint and the instrumental constraint', () {
      final prompt = buildAudioPrompt(
        'Base.',
        const WellnessProfile(mood: Mood.stressed),
      );
      expect(
        prompt,
        'Base. Mood adaptation: Use very gentle pacing that encourages slow '
        'breathing. Instrumental only, no vocals.',
      );
    });

    test('omits the hint without a mood', () {
      expect(
        buildAudioPrompt('Base.', noMood),
        'Base. Instrumental only, no vocals.',
      );
    });
  });
}
