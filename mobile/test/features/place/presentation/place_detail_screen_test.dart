import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tenaspace/features/feed/data/wellness_feed_repository.dart';
import 'package:tenaspace/features/feed/domain/wellness_feed.dart';
import 'package:tenaspace/features/feed/domain/wellness_place.dart';
import 'package:tenaspace/features/feed/domain/wellness_section.dart';
import 'package:tenaspace/features/place/application/saved_places_controller.dart';
import 'package:tenaspace/features/place/application/sound_player_controller.dart';
import 'package:tenaspace/features/place/presentation/place_detail_screen.dart';
import 'package:tenaspace/features/profile/domain/wellness_profile.dart';

import '../../../helpers/test_helpers.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _StaticFeedRepository implements WellnessFeedRepository {
  const _StaticFeedRepository(this.feed);

  final WellnessFeed feed;

  @override
  Future<WellnessFeed> fetchCuratedFeed(WellnessProfile profile) async => feed;
}

/// A move place without coordinates: exercises the "no map" branch and the
/// AI (non-static) sound player without touching the network.
const _trackWithoutCoordinates = WellnessPlace(
  id: 'jan-meda-track',
  emoji: '🏃',
  name: 'Jan Meda Track',
  category: 'Walking route',
  distanceKm: 2.4,
  recommendation: 'Soft grass loops for an easy walk.',
  section: WellnessSection.move,
  tags: ['walking', 'grass'],
  bestTime: 'Early morning',
);

const _feed = WellnessFeed(
  featured: _trackWithoutCoordinates,
  sections: [
    WellnessFeedSection(
      section: WellnessSection.move,
      title: '🏃 Move Your Body',
      places: [_trackWithoutCoordinates],
    ),
  ],
);

void main() {
  late _MockAudioPlayer player;

  setUp(() {
    player = _MockAudioPlayer();
    when(() => player.dispose()).thenAnswer((_) async {});
  });

  Future<ProviderContainer> pumpDetail(WidgetTester tester) async {
    usePhoneViewport(tester);
    final prefs = await fakePreferences();
    final container = createContainer(
      overrides: [
        ...baseOverrides(prefs),
        wellnessFeedRepositoryProvider.overrideWithValue(
          const _StaticFeedRepository(_feed),
        ),
        audioPlayerFactoryProvider.overrideWithValue(() => player),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PlaceDetailScreen(placeId: 'jan-meda-track'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('renders the derived detail view-model', (tester) async {
    await pumpDetail(tester);

    expect(find.text('Jan Meda Track'), findsOneWidget);
    expect(find.text('Walking route · 2.4 km away'), findsOneWidget);
    expect(find.text('Soft grass loops for an easy walk.'), findsOneWidget);
    // 2.4 km at 4.8 km/h → 30 minutes, derived because the category says "walk".
    expect(find.text('30 min estimated walk'), findsOneWidget);
    expect(find.text('Best time: Early morning'), findsOneWidget);
    expect(
      find.text('Map coordinates are not available for this place yet.'),
      findsOneWidget,
    );
    // Default actions for a move place without coordinates: timer, audio, save.
    expect(find.text('Start a 30-minute activity'), findsOneWidget);
    expect(find.text('Get directions'), findsNothing);
    expect(find.text('Save this place'), findsOneWidget);
    expect(find.text('AI SOUND'), findsOneWidget);

    // Tags sit below the fold; the ListView only builds them once scrolled.
    await tester.scrollUntilVisible(
      find.text('walking'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('walking'), findsOneWidget);
    expect(find.text('grass'), findsOneWidget);
  });

  testWidgets('the header Save button toggles the bookmark', (tester) async {
    final container = await pumpDetail(tester);

    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsOneWidget);
    expect(container.read(savedPlacesControllerProvider), {'jan-meda-track'});

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('unknown ids show the not-found state once the feed settles', (
    tester,
  ) async {
    usePhoneViewport(tester);
    final prefs = await fakePreferences();
    await tester.pumpWidget(
      wrapForTest(
        const PlaceDetailScreen(placeId: 'nope'),
        overrides: [
          ...baseOverrides(prefs),
          wellnessFeedRepositoryProvider.overrideWithValue(
            const _StaticFeedRepository(_feed),
          ),
        ],
      ),
    );

    expect(find.text('Loading place details...'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Place not found'), findsOneWidget);
  });
}
