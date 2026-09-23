import 'package:flutter/foundation.dart';

/// Marker interface shared by every onboarding option enum, so the onboarding
/// UI can render any step generically while the controller pattern-matches on
/// the concrete type to update the right profile field.
sealed class ProfileOption {
  /// Value sent over the wire — identical to the TypeScript union strings.
  String get wire;
  String get emoji;
  String get label;
}

enum Goal implements ProfileOption {
  active('active', '🏃', 'Stay active'),
  eat('eat', '🥗', 'Eat healthier'),
  stress('stress', '🧘', 'Reduce stress'),
  medical('medical', '🏥', 'Find medical support'),
  discover('discover', '🗺️', 'Discover wellness places');

  const Goal(this.wire, this.emoji, this.label);

  @override
  final String wire;
  @override
  final String emoji;
  @override
  final String label;

  static Goal? fromWire(String? value) => _byWire(values, value);
}

enum Interest implements ProfileOption {
  basketball('basketball', '🏀', 'Basketball'),
  football('football', '⚽', 'Football'),
  tennis('tennis', '🎾', 'Tennis'),
  running('running', '🏃', 'Running'),
  gym('gym', '🏋️', 'Gym'),
  yoga('yoga', '🧘', 'Yoga / Meditation'),
  walking('walking', '🚶', 'Walking'),
  cafes('cafes', '☕', 'Healthy cafes');

  const Interest(this.wire, this.emoji, this.label);

  @override
  final String wire;
  @override
  final String emoji;
  @override
  final String label;

  static Interest? fromWire(String? value) => _byWire(values, value);
}

enum Diet implements ProfileOption {
  diabetic('diabetic', '🩺', 'Diabetic-friendly meals'),
  lowSugar('low-sugar', '🍯', 'Low sugar'),
  highProtein('high-protein', '🥩', 'High protein'),
  vegetarian('vegetarian', '🥬', 'Vegetarian'),
  weight('weight', '⚖️', 'Weight management'),
  heart('heart', '❤️', 'Heart-friendly'),
  none('none', '✨', 'No specific preference');

  const Diet(this.wire, this.emoji, this.label);

  @override
  final String wire;
  @override
  final String emoji;
  @override
  final String label;

  static Diet? fromWire(String? value) => _byWire(values, value);
}

enum Mood implements ProfileOption {
  calm('calm', '😌', 'Calm'),
  stressed('stressed', '😣', 'Stressed'),
  tired('tired', '😴', 'Tired'),
  anxious('anxious', '😰', 'Anxious'),
  motivated('motivated', '💪', 'Motivated'),
  freshAir('fresh-air', '💨', 'Need fresh air');

  const Mood(this.wire, this.emoji, this.label);

  @override
  final String wire;
  @override
  final String emoji;
  @override
  final String label;

  static Mood? fromWire(String? value) => _byWire(values, value);
}

T? _byWire<T extends ProfileOption>(List<T> values, String? wire) {
  if (wire == null) return null;
  for (final value in values) {
    if (value.wire == wire) return value;
  }
  return null;
}

/// What the app knows about the user after onboarding. Immutable; every
/// mutation goes through [copyWith] so Riverpod can detect changes with `==`.
@immutable
final class WellnessProfile {
  const WellnessProfile({
    this.goals = const {},
    this.interests = const {},
    this.diets = const {},
    this.mood,
  });

  factory WellnessProfile.fromJson(Map<String, dynamic> json) {
    return WellnessProfile(
      goals: _readSet(json['goals'], Goal.fromWire),
      interests: _readSet(json['interests'], Interest.fromWire),
      diets: _readSet(json['diets'], Diet.fromWire),
      mood: Mood.fromWire(json['mood'] as String?),
    );
  }

  static const empty = WellnessProfile();

  final Set<Goal> goals;
  final Set<Interest> interests;
  final Set<Diet> diets;
  final Mood? mood;

  bool get isEmpty =>
      goals.isEmpty && interests.isEmpty && diets.isEmpty && mood == null;

  WellnessProfile copyWith({
    Set<Goal>? goals,
    Set<Interest>? interests,
    Set<Diet>? diets,
    Mood? mood,
    bool clearMood = false,
  }) {
    return WellnessProfile(
      goals: goals ?? this.goals,
      interests: interests ?? this.interests,
      diets: diets ?? this.diets,
      mood: clearMood ? null : (mood ?? this.mood),
    );
  }

  /// Shape expected by `POST /api/wellness-feed`. Sets are emitted in enum
  /// declaration order so the payload is deterministic.
  Map<String, dynamic> toJson() => {
    'goals': _sorted(goals).map((goal) => goal.wire).toList(),
    'interests': _sorted(interests).map((item) => item.wire).toList(),
    'diets': _sorted(diets).map((diet) => diet.wire).toList(),
    'mood': mood?.wire,
  };

  static Set<T> _readSet<T>(Object? raw, T? Function(String?) parse) {
    if (raw is! List) return const {};
    return {
      for (final entry in raw)
        if (entry is String && parse(entry) != null) parse(entry)!,
    };
  }

  static List<T> _sorted<T extends Enum>(Set<T> values) =>
      values.toList()..sort((a, b) => a.index.compareTo(b.index));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessProfile &&
          setEquals(goals, other.goals) &&
          setEquals(interests, other.interests) &&
          setEquals(diets, other.diets) &&
          mood == other.mood;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(goals),
    Object.hashAllUnordered(interests),
    Object.hashAllUnordered(diets),
    mood,
  );

  @override
  String toString() =>
      'WellnessProfile(goals: $goals, interests: $interests, '
      'diets: $diets, mood: $mood)';
}
