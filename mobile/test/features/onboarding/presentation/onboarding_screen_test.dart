import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenaspace/core/widgets/pill_button.dart';
import 'package:tenaspace/features/onboarding/presentation/onboarding_screen.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Future<void> pumpOnboarding(WidgetTester tester) async {
    usePhoneViewport(tester);
    final prefs = await fakePreferences();
    await tester.pumpWidget(
      wrapForTest(const OnboardingScreen(), overrides: baseOverrides(prefs)),
    );
  }

  PillButton continueButton(WidgetTester tester) =>
      tester.widget<PillButton>(find.byType(PillButton));

  testWidgets('shows step one and keeps Continue disabled until a choice', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('What do you want help with today?'), findsOneWidget);
    expect(find.text('Stay active'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNull);
  });

  testWidgets('selecting a card enables Continue and advances the step', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('Stay active'));
    await tester.pumpAndSettle();

    expect(find.text('SELECTED'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 4'), findsOneWidget);
    expect(find.text('What activities match your lifestyle?'), findsOneWidget);
    expect(find.text('Basketball'), findsOneWidget);
  });

  testWidgets('the header back button returns to the previous step', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('Eat healthier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 4'), findsOneWidget);
    // The draft survives navigating back.
    expect(find.text('SELECTED'), findsOneWidget);
  });

  testWidgets('the final step offers to create the wellness map', (
    tester,
  ) async {
    await pumpOnboarding(tester);

    for (final choice in ['Stay active', 'Walking', 'Low sugar']) {
      await scrollAndTapText(tester, choice);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text('Create My Wellness Map'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNull);

    await tester.tap(find.text('Calm'));
    await tester.pumpAndSettle();
    expect(continueButton(tester).onPressed, isNotNull);
  });
}
