import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/domain/wellness_profile.dart';

/// Copy for one onboarding step; the options come straight from the enums.
@immutable
final class OnboardingStepContent {
  const OnboardingStepContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.options,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<ProfileOption> options;
}

const onboardingSteps = <OnboardingStepContent>[
  OnboardingStepContent(
    eyebrow: 'Wellness Goal',
    title: 'What do you want help with today?',
    subtitle: 'Select all that apply.',
    options: Goal.values,
  ),
  OnboardingStepContent(
    eyebrow: 'Lifestyle',
    title: 'What activities match your lifestyle?',
    subtitle: 'We use this to recommend the right places, not random places.',
    options: Interest.values,
  ),
  OnboardingStepContent(
    eyebrow: 'Health & Diet',
    title: 'Do you have any diet or health preferences?',
    subtitle: 'TenaSpace gives wellness suggestions, not medical advice.',
    options: Diet.values,
  ),
  OnboardingStepContent(
    eyebrow: 'Mood Check',
    title: 'How are you feeling lately?',
    subtitle: "Your mood shapes today's recommendations.",
    options: Mood.values,
  ),
];

@immutable
final class OnboardingState {
  const OnboardingState({this.step = 0, this.draft = WellnessProfile.empty});

  static int get stepCount => onboardingSteps.length;

  final int step;

  /// Edits live here until the user taps "Create My Wellness Map"; only then
  /// is the draft committed to [ProfileController].
  final WellnessProfile draft;

  OnboardingStepContent get content => onboardingSteps[step];
  bool get isFirstStep => step == 0;
  bool get isLastStep => step == stepCount - 1;
  double get progress => (step + 1) / stepCount;

  bool get canContinue => switch (step) {
    0 => draft.goals.isNotEmpty,
    1 => draft.interests.isNotEmpty,
    2 => draft.diets.isNotEmpty,
    _ => draft.mood != null,
  };

  bool isSelected(ProfileOption option) => switch (option) {
    Goal() => draft.goals.contains(option),
    Interest() => draft.interests.contains(option),
    Diet() => draft.diets.contains(option),
    Mood() => draft.mood == option,
  };

  OnboardingState copyWith({int? step, WellnessProfile? draft}) =>
      OnboardingState(step: step ?? this.step, draft: draft ?? this.draft);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState && step == other.step && draft == other.draft;

  @override
  int get hashCode => Object.hash(step, draft);
}

/// Drives the 4-step profile builder. `autoDispose` resets the draft as soon
/// as the user leaves onboarding, so a second visit always starts clean.
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Multi-select steps toggle; the mood step is single-select.
  void toggle(ProfileOption option) {
    final draft = state.draft;
    state = state.copyWith(
      draft: switch (option) {
        Goal() => draft.copyWith(goals: _toggled(draft.goals, option)),
        Interest() => draft.copyWith(
          interests: _toggled(draft.interests, option),
        ),
        Diet() => draft.copyWith(diets: _toggled(draft.diets, option)),
        Mood() => draft.copyWith(mood: option),
      },
    );
  }

  /// Advances when the current step is satisfied. Returns false on the last
  /// step so the caller knows to finish instead.
  bool next() {
    if (!state.canContinue || state.isLastStep) return false;
    state = state.copyWith(step: state.step + 1);
    return true;
  }

  /// Returns false when already on the first step (caller leaves onboarding).
  bool back() {
    if (state.isFirstStep) return false;
    state = state.copyWith(step: state.step - 1);
    return true;
  }

  static Set<T> _toggled<T>(Set<T> items, T value) =>
      items.contains(value) ? ({...items}..remove(value)) : {...items, value};
}

final onboardingControllerProvider =
    NotifierProvider.autoDispose<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
