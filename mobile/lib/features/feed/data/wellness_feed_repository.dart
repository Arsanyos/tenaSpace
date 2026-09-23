import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../profile/domain/wellness_profile.dart';
import '../domain/wellness_feed.dart';
import 'mock_wellness_feed.dart';

/// Thrown when the server answers but the payload has no usable places.
class FeedCurationException implements Exception {
  const FeedCurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Boundary between the app and "wherever the feed comes from". Widgets and
/// controllers only ever see this interface, which is what lets tests (and
/// mock mode) swap the implementation through a single provider override.
abstract interface class WellnessFeedRepository {
  Future<WellnessFeed> fetchCuratedFeed(WellnessProfile profile);
}

/// Talks to the Next.js route that proxies Groq (`POST /api/wellness-feed`).
final class ApiWellnessFeedRepository implements WellnessFeedRepository {
  const ApiWellnessFeedRepository(this._client);

  static const path = '/api/wellness-feed';

  final ApiClient _client;

  @override
  Future<WellnessFeed> fetchCuratedFeed(WellnessProfile profile) async {
    final json = await _client.postJson(path, profile.toJson());
    final feed = WellnessFeed.fromJson(json);
    if (feed == null || !feed.hasPlaces) {
      throw const FeedCurationException(
        'Groq returned a feed, but it did not contain valid places.',
      );
    }
    return feed;
  }
}

/// Offline stand-in used by `USE_MOCK_API=true`; the delay keeps the loading
/// state visible so the UI can be demoed end to end.
final class MockWellnessFeedRepository implements WellnessFeedRepository {
  const MockWellnessFeedRepository({
    this.delay = const Duration(milliseconds: 900),
  });

  final Duration delay;

  @override
  Future<WellnessFeed> fetchCuratedFeed(WellnessProfile profile) async {
    await Future<void>.delayed(delay);
    return mockWellnessFeed;
  }
}

final wellnessFeedRepositoryProvider = Provider<WellnessFeedRepository>((ref) {
  if (ref.watch(appConfigProvider).useMockApi) {
    return const MockWellnessFeedRepository();
  }
  return ApiWellnessFeedRepository(ref.watch(apiClientProvider));
});
