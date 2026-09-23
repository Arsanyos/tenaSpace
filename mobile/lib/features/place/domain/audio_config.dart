import 'package:flutter/foundation.dart';

import '../../feed/domain/wellness_place.dart';
import '../../feed/domain/wellness_section.dart';
import '../../profile/domain/wellness_profile.dart';

/// Port of `lib/audio-config.ts`: decides *which* background sound a place
/// gets and builds the generation prompt from the user's mood.
@immutable
final class AudioConfig {
  const AudioConfig({
    required this.kind,
    required this.label,
    required this.basePrompt,
    required this.durationSeconds,
    this.loop = true,
    this.staticPath,
  });

  final AudioKind kind;
  final String label;
  final String basePrompt;
  final int durationSeconds;
  final bool loop;

  /// When set, the player streams this file from the Next.js `public/` folder
  /// instead of calling the AI endpoint (e.g. `/audio/calm-meditation.mp3`).
  final String? staticPath;

  bool get isStatic => staticPath != null;
}

/// An [AudioConfig] with the mood-aware prompt already rendered.
@immutable
final class ResolvedAudioConfig {
  const ResolvedAudioConfig({required this.base, required this.prompt});

  final AudioConfig base;
  final String prompt;

  AudioKind get kind => base.kind;
  String get label => base.label;
  int get durationSeconds => base.durationSeconds;
  bool get loop => base.loop;
  String? get staticPath => base.staticPath;
  bool get isStatic => base.isStatic;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedAudioConfig &&
          base.kind == other.base.kind &&
          base.label == other.base.label &&
          base.staticPath == other.base.staticPath &&
          base.durationSeconds == other.base.durationSeconds &&
          prompt == other.prompt;

  @override
  int get hashCode => Object.hash(
    base.kind,
    base.label,
    base.staticPath,
    base.durationSeconds,
    prompt,
  );
}

const _walkingLabel = 'Play AI walking soundscape';
const _calmLabel = 'Play calm background sound';

const Map<WellnessSection, AudioConfig?> _defaultAudioBySection = {
  WellnessSection.move: AudioConfig(
    kind: AudioKind.walkingMix,
    label: _walkingLabel,
    basePrompt:
        'Instrumental walking ambience with gentle rhythm, warm Ethiopian-inspired '
        'textures, soft percussion, and a positive steady pace.',
    durationSeconds: 35,
  ),
  WellnessSection.eat: null,
  WellnessSection.calm: AudioConfig(
    kind: AudioKind.meditation,
    label: _calmLabel,
    basePrompt:
        'Slow meditative ambient soundscape with soft sustained pads, light wind, '
        'and very gentle Ethiopian-inspired acoustic textures.',
    durationSeconds: 45,
    staticPath: '/audio/calm-meditation.mp3',
  ),
  WellnessSection.health: null,
};

const Map<String, AudioConfig> _audioByPlace = {
  'meskel-walk': AudioConfig(
    kind: AudioKind.walkingMix,
    label: _walkingLabel,
    basePrompt:
        'Uplifting morning walking ambience with gentle motion, soft city air, '
        'subtle Ethiopian krar plucks, and calm focus energy.',
    durationSeconds: 40,
  ),
  'entoto-view': AudioConfig(
    kind: AudioKind.meditation,
    label: _calmLabel,
    basePrompt:
        'Peaceful mountain-top meditation ambience with spacious wind, distant '
        'birds, and slow grounding ambient pads.',
    durationSeconds: 50,
    staticPath: '/audio/entoto-meditation.mp3',
  ),
  'ghion-garden': AudioConfig(
    kind: AudioKind.meditation,
    label: _calmLabel,
    basePrompt:
        'Quiet garden meditation ambience with warm pads, soft natural textures, '
        'and a deeply relaxing low-energy pace.',
    durationSeconds: 45,
    staticPath: '/audio/ghion-meditation.mp3',
  ),
};

const Map<Mood, String> _moodHints = {
  Mood.calm: 'Keep the sound soft and steady.',
  Mood.stressed: 'Use very gentle pacing that encourages slow breathing.',
  Mood.tired: 'Use warm low-energy tones for recovery.',
  Mood.anxious: 'Use grounding low textures with minimal sudden changes.',
  Mood.motivated: 'Add subtle uplifting motion while staying calm.',
  Mood.freshAir: 'Blend airy outdoor textures and light breeze.',
};

AudioConfig? _baseAudioConfig(WellnessPlace place) {
  if (place.audioKind == AudioKind.none) return null;
  // An explicit kind from Groq trumps the hand-tuned per-place overrides.
  if (place.audioKind != null) return _defaultAudioBySection[place.section];
  return _audioByPlace[place.id] ?? _defaultAudioBySection[place.section];
}

String buildAudioPrompt(String basePrompt, WellnessProfile profile) {
  final mood = profile.mood;
  final moodHint = mood == null ? '' : ' Mood adaptation: ${_moodHints[mood]}';
  return '$basePrompt$moodHint Instrumental only, no vocals.';
}

ResolvedAudioConfig? resolveAudioConfig(
  WellnessPlace place,
  WellnessProfile profile,
) {
  final base = _baseAudioConfig(place);
  if (base == null) return null;
  return ResolvedAudioConfig(
    base: base,
    prompt: buildAudioPrompt(base.basePrompt, profile),
  );
}
