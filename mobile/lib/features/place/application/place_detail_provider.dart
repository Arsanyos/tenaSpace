import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../feed/application/feed_controller.dart';
import '../../feed/data/feed_cache.dart';
import '../../feed/domain/wellness_place.dart';
import '../../profile/application/profile_controller.dart';
import '../domain/place_detail.dart';

/// Looks a place up by id in the live feed first, then in the on-disk cache
/// (cold-start deep links), and derives the detail view-model from it.
///
/// Pure derivation — no I/O — so it is cheap to `autoDispose` and trivial to
/// test by overriding the two providers it reads.
final placeDetailProvider = Provider.autoDispose.family<PlaceDetail?, String>((
  ref,
  placeId,
) {
  final profile = ref.watch(profileControllerProvider);
  final liveFeed = ref.watch(feedControllerProvider).value;

  WellnessPlace? place = liveFeed?.findPlace(placeId);
  place ??= ref.watch(feedCacheProvider).read()?.findPlace(placeId);
  if (place == null) return null;

  return PlaceDetail.fromPlace(place, profile);
});
