import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../feed/application/feed_controller.dart';
import '../../feed/data/feed_cache.dart';
import '../../feed/domain/wellness_section.dart';
import '../domain/map_place.dart';

/// Every curated place with coordinates, projected for the map. Derived from
/// the live feed (falling back to the on-disk cache after a cold start).
final mapPlacesProvider = Provider<List<MapPlace>>((ref) {
  final feed =
      ref.watch(feedControllerProvider).value ??
      ref.watch(feedCacheProvider).read();
  if (feed == null) return const [];

  return feed.allPlaces.map(MapPlace.fromPlace).whereType<MapPlace>().toList();
});

@immutable
final class MapScreenState {
  const MapScreenState({this.filter, this.selectedId});

  /// `null` means "All".
  final WellnessSection? filter;
  final String? selectedId;

  MapScreenState copyWith({
    WellnessSection? filter,
    bool clearFilter = false,
    String? selectedId,
    bool clearSelection = false,
  }) {
    return MapScreenState(
      filter: clearFilter ? null : (filter ?? this.filter),
      selectedId: clearSelection ? null : (selectedId ?? this.selectedId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapScreenState &&
          filter == other.filter &&
          selectedId == other.selectedId;

  @override
  int get hashCode => Object.hash(filter, selectedId);
}

/// UI state shared by the preview map, the nearby list and the expanded
/// sheet — three sibling widgets, which is exactly when local `setState`
/// stops being enough.
class MapScreenController extends Notifier<MapScreenState> {
  @override
  MapScreenState build() => const MapScreenState();

  void setFilter(WellnessSection? section) {
    state = MapScreenState(filter: section);
  }

  void select(String? placeId) {
    state = placeId == null
        ? state.copyWith(clearSelection: true)
        : state.copyWith(selectedId: placeId);
  }
}

final mapScreenControllerProvider =
    NotifierProvider.autoDispose<MapScreenController, MapScreenState>(
      MapScreenController.new,
    );

/// Places matching the active filter.
final filteredMapPlacesProvider = Provider.autoDispose<List<MapPlace>>((ref) {
  final filter = ref.watch(
    mapScreenControllerProvider.select((state) => state.filter),
  );
  final places = ref.watch(mapPlacesProvider);
  if (filter == null) return places;
  return places.where((place) => place.section == filter).toList();
});

/// The first five curated places are flagged "For you" (web: `highlightedIds`).
final highlightedMapPlaceIdsProvider = Provider.autoDispose<Set<String>>((ref) {
  return ref.watch(mapPlacesProvider).take(5).map((place) => place.id).toSet();
});
