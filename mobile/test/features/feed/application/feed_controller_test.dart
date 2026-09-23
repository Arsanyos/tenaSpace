import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tenaspace/core/network/api_client.dart';
import 'package:tenaspace/features/feed/application/feed_controller.dart';
import 'package:tenaspace/features/feed/data/feed_cache.dart';
import 'package:tenaspace/features/feed/domain/wellness_feed.dart';
import 'package:tenaspace/features/profile/application/profile_controller.dart';
import 'package:tenaspace/features/profile/data/profile_storage.dart';
import 'package:tenaspace/features/profile/domain/wellness_profile.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('FeedController', () {
    late List<http.Request> requests;

    /// Full-stack container: real ApiClient + repository, fake transport.
    Future<ProviderContainer> buildContainer(
      Future<http.Response> Function(http.Request) handler, {
      Map<String, Object> storedValues = const {},
    }) async {
      requests = [];
      final prefs = await fakePreferences(storedValues);
      return createContainer(
        overrides: [
          ...baseOverrides(prefs),
          httpClientProvider.overrideWithValue(
            MockClient((request) {
              requests.add(request);
              return handler(request);
            }),
          ),
        ],
      );
    }

    test('posts the committed profile and exposes the parsed feed', () async {
      const profile = WellnessProfile(goals: {Goal.active}, mood: Mood.calm);
      final container = await buildContainer(
        (_) async => jsonResponse(curatedFeedJson),
        storedValues: {ProfileStorage.storageKey: jsonEncode(profile.toJson())},
      );

      final feed = await container.read(feedControllerProvider.future);

      expect(feed.featured.id, 'meskel-walk');
      expect(requests, hasLength(1));
      expect(requests.single.url.path, '/api/wellness-feed');
      expect(jsonDecode(requests.single.body), profile.toJson());
    });

    test('caches the curated feed on disk for cold starts', () async {
      final container = await buildContainer(
        (_) async => jsonResponse(curatedFeedJson),
      );

      final feed = await container.read(feedControllerProvider.future);

      expect(container.read(feedCacheProvider).read(), feed);
    });

    test('exposes the server error without retrying on its own', () async {
      final container = await buildContainer(
        (_) async => jsonResponse({
          'error': 'Could not curate wellness feed.',
        }, status: 503),
      );

      await settle(container, feedControllerProvider);
      final state = container.read(feedControllerProvider);

      expect(state, isA<AsyncError<WellnessFeed>>());
      expect(
        state.error,
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Could not curate wellness feed.',
        ),
      );
      expect(requests, hasLength(1));
    });

    test('refresh() re-runs curation after a failure', () async {
      var attempts = 0;
      final container = await buildContainer((_) async {
        attempts++;
        return attempts == 1
            ? jsonResponse({'error': 'flaky'}, status: 503)
            : jsonResponse(curatedFeedJson);
      });

      await settle(container, feedControllerProvider);
      expect(container.read(feedControllerProvider).hasError, isTrue);

      await container.read(feedControllerProvider.notifier).refresh();

      expect(container.read(feedControllerProvider).hasValue, isTrue);
      expect(attempts, 2);
    });

    test('re-curates when a new profile is committed', () async {
      final container = await buildContainer(
        (_) async => jsonResponse(curatedFeedJson),
      );
      await settle(container, feedControllerProvider);
      expect(requests, hasLength(1));

      const updated = WellnessProfile(goals: {Goal.medical});
      await container.read(profileControllerProvider.notifier).commit(updated);
      await container.read(feedControllerProvider.future);

      expect(requests, hasLength(2));
      expect(jsonDecode(requests.last.body), updated.toJson());
    });
  });
}
