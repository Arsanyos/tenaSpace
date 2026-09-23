import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/application/profile_controller.dart';
import '../data/feed_cache.dart';
import '../data/wellness_feed_repository.dart';
import '../domain/wellness_feed.dart';

/// Curates the feed for the committed profile.
///
/// * `ref.watch(profileControllerProvider)` makes the feed **derived state**:
///   commit a new profile and the feed re-curates itself — no manual wiring.
/// * The provider is kept alive (not `autoDispose`), so switching between the
///   Home and Map tabs never re-triggers the multi-second Groq call.
/// * Automatic retry is disabled: the UI owns retries via [refresh], matching
///   the web's explicit "Try again" button.
class FeedController extends AsyncNotifier<WellnessFeed> {
  @override
  Future<WellnessFeed> build() async {
    final profile = ref.watch(profileControllerProvider);
    final repository = ref.watch(wellnessFeedRepositoryProvider);
    final cache = ref.read(feedCacheProvider);

    final feed = await repository.fetchCuratedFeed(profile);
    // A failed cache write must never take the freshly loaded feed down.
    try {
      await cache.write(feed);
    } on Exception {
      // Ignore — the feed is still valid in memory.
    }
    return feed;
  }

  /// Re-runs curation and completes when the new state has settled.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } on Exception {
      // The error is already surfaced through [state]; nothing else to do.
    }
  }
}

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, WellnessFeed>(
      FeedController.new,
      retry: (retryCount, error) => null,
    );
