import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tenaspace/core/routing/app_router.dart';
import 'package:tenaspace/features/onboarding/presentation/splash_screen.dart';
import 'package:tenaspace/features/profile/application/profile_controller.dart';
import 'package:tenaspace/features/profile/data/profile_storage.dart';
import 'package:tenaspace/features/profile/domain/wellness_profile.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Future<ProviderContainer> pumpSplash(WidgetTester tester) async {
    usePhoneViewport(tester);
    final prefs = await fakePreferences({
      ProfileStorage.storageKey:
          '{"goals":["active"],"interests":[],"diets":[],"mood":null}',
    });
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, _) => const Text('ONBOARDING'),
        ),
        GoRoute(
          path: AppRoutes.preparing,
          builder: (_, _) => const Text('PREPARING'),
        ),
      ],
    );
    addTearDown(router.dispose);

    final container = createContainer(overrides: baseOverrides(prefs));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    return container;
  }

  testWidgets('renders the pitch and both calls to action', (tester) async {
    await pumpSplash(tester);

    expect(find.text('TenaSpace'), findsOneWidget);
    expect(find.textContaining('Your wellness,'), findsOneWidget);
    expect(find.text('Start Your Wellness Profile'), findsOneWidget);
    expect(find.text('Explore as Guest'), findsOneWidget);
  });

  testWidgets('Start pushes the onboarding route', (tester) async {
    await pumpSplash(tester);

    await scrollAndTapText(tester, 'Start Your Wellness Profile');

    expect(find.text('ONBOARDING'), findsOneWidget);
  });

  testWidgets('Explore as Guest commits an empty profile and moves on', (
    tester,
  ) async {
    final container = await pumpSplash(tester);
    expect(container.read(profileControllerProvider).isEmpty, isFalse);

    await scrollAndTapText(tester, 'Explore as Guest');

    expect(find.text('PREPARING'), findsOneWidget);
    expect(container.read(profileControllerProvider), WellnessProfile.empty);
  });
}
