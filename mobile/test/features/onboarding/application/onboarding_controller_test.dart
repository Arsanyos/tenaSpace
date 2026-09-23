import 'package:flutter_test/flutter_test.dart';
import 'package:tenaspace/features/onboarding/application/onboarding_controller.dart';
import 'package:tenaspace/features/profile/domain/wellness_profile.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('OnboardingController', () {
    test('starts on step one with an empty draft and cannot continue', () {
      final container = createContainer();
      container.listen(onboardingControllerProvider, (_, _) {});

      final state = container.read(onboardingControllerProvider);
      expect(state.step, 0);
      expect(state.draft, WellnessProfile.empty);
      expect(state.canContinue, isFalse);
      expect(state.content.eyebrow, 'Wellness Goal');
      expect(OnboardingState.stepCount, 4);
    });

    test('toggles multi-select options on and off', () {
      final container = createContainer();
      container.listen(onboardingControllerProvider, (_, _) {});
      final controller = container.read(onboardingControllerProvider.notifier);

      controller.toggle(Goal.active);
      controller.toggle(Goal.stress);
      expect(container.read(onboardingControllerProvider).draft.goals, {
        Goal.active,
        Goal.stress,
      });
      expect(
        container.read(onboardingControllerProvider).isSelected(Goal.active),
        isTrue,
      );

      controller.toggle(Goal.active);
      expect(container.read(onboardingControllerProvider).draft.goals, {
        Goal.stress,
      });
      expect(
        container.read(onboardingControllerProvider).isSelected(Goal.active),
        isFalse,
      );
    });

    test('mood is single-select', () {
      final container = createContainer();
      container.listen(onboardingControllerProvider, (_, _) {});
      final controller = container.read(onboardingControllerProvider.notifier);

      controller.toggle(Mood.tired);
      controller.toggle(Mood.calm);

      final state = container.read(onboardingControllerProvider);
      expect(state.draft.mood, Mood.calm);
      expect(state.isSelected(Mood.calm), isTrue);
      expect(state.isSelected(Mood.tired), isFalse);
    });

    test('next() is gated by canContinue and stops on the last step', () {
      final container = createContainer();
      container.listen(onboardingControllerProvider, (_, _) {});
      final controller = container.read(onboardingControllerProvider.notifier);

      expect(controller.next(), isFalse);
      expect(container.read(onboardingControllerProvider).step, 0);

      controller.toggle(Goal.eat);
      expect(controller.next(), isTrue);
      expect(container.read(onboardingControllerProvider).step, 1);
      expect(container.read(onboardingControllerProvider).progress, 0.5);

      controller.toggle(Interest.cafes);
      controller.next();
      controller.toggle(Diet.diabetic);
      controller.next();
      controller.toggle(Mood.motivated);

      final last = container.read(onboardingControllerProvider);
      expect(last.isLastStep, isTrue);
      expect(last.canContinue, isTrue);
      expect(controller.next(), isFalse, reason: 'caller commits instead');
    });

    test('back() walks to the first step and then reports false', () {
      final container = createContainer();
      container.listen(onboardingControllerProvider, (_, _) {});
      final controller = container.read(onboardingControllerProvider.notifier);

      controller.toggle(Goal.eat);
      controller.next();

      expect(controller.back(), isTrue);
      expect(container.read(onboardingControllerProvider).step, 0);
      expect(controller.back(), isFalse);
    });
  });
}
