import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tenaspace/core/network/api_client.dart';
import 'package:tenaspace/features/feed/data/mock_wellness_feed.dart';
import 'package:tenaspace/features/feed/data/wellness_feed_repository.dart';
import 'package:tenaspace/features/feed/domain/wellness_feed.dart';
import 'package:tenaspace/features/feed/presentation/feed_screen.dart';
import 'package:tenaspace/features/profile/domain/wellness_profile.dart';

import '../../../helpers/test_helpers.dart';

/// Scripted repository: each call pops the next result off the queue.
class _ScriptedFeedRepository implements WellnessFeedRepository {
  _ScriptedFeedRepository(this._results);

  final List<FutureOr<WellnessFeed> Function()> _results;
  int calls = 0;

  @override
  Future<WellnessFeed> fetchCuratedFeed(WellnessProfile profile) async {
    calls++;
    return _results.removeAt(0)();
  }
}

void main() {
  Future<void> pumpFeed(
    WidgetTester tester,
    WellnessFeedRepository repository,
  ) async {
    final prefs = await fakePreferences();
    final router = GoRouter(
      initialLocation: '/feed',
      routes: [
        GoRoute(path: '/feed', builder: (_, _) => const FeedScreen()),
        GoRoute(
          path: '/place/:id',
          builder: (_, state) => Text('PLACE ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          ...baseOverrides(prefs),
          wellnessFeedRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('shows a loading state, then the curated feed', (tester) async {
    final completer = Completer<WellnessFeed>();
    await pumpFeed(tester, _ScriptedFeedRepository([() => completer.future]));

    expect(find.text('Groq is curating your places...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(mockWellnessFeed);
    await tester.pumpAndSettle();

    expect(find.text("✨ TODAY'S WELLNESS MATCH"), findsOneWidget);
    expect(find.text(mockWellnessFeed.featured.name), findsOneWidget);
    expect(
      find.text('Curated for your goals, interests, and mood.'),
      findsOneWidget,
    );
    expect(find.text('🏃 Move Your Body'), findsOneWidget);
    expect(find.text('Bole Community Basketball Court'), findsOneWidget);
  });

  testWidgets('renders the empty state and recovers via Try again', (
    tester,
  ) async {
    final repository = _ScriptedFeedRepository([
      () => throw const ApiException('GROQ_API_KEY is missing'),
      () => mockWellnessFeed,
    ]);
    await pumpFeed(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('No data to display'), findsOneWidget);
    expect(find.text('GROQ_API_KEY is missing'), findsOneWidget);
    expect(find.text('We could not load your curated plan.'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text(mockWellnessFeed.featured.name), findsOneWidget);
  });

  testWidgets('tapping a card routes to that place', (tester) async {
    await pumpFeed(tester, _ScriptedFeedRepository([() => mockWellnessFeed]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open match details →'));
    await tester.pumpAndSettle();

    expect(find.text('PLACE ${mockWellnessFeed.featured.id}'), findsOneWidget);
  });
}
