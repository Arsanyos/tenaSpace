import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../feed/domain/wellness_place.dart';
import '../../feed/domain/wellness_section.dart';

/// Addis Ababa city centre — default camera when no places have coordinates.
const addisMapCenter = LatLng(9.032, 38.747);
const addisMapZoom = 13.0;

/// A place projected onto the map: only the fields the marker layer needs.
@immutable
final class MapPlace {
  const MapPlace({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.section,
    required this.lat,
    required this.lng,
    required this.distanceKm,
  });

  /// `null` when the curated place has no coordinates (mirrors `toMapPlace`).
  static MapPlace? fromPlace(WellnessPlace place) {
    final lat = place.lat;
    final lng = place.lng;
    if (lat == null || lng == null) return null;

    return MapPlace(
      id: place.id,
      name: place.name,
      emoji: place.emoji,
      category: place.category,
      section: place.section,
      lat: lat,
      lng: lng,
      distanceKm: place.distanceKm,
    );
  }

  final String id;
  final String name;
  final String emoji;
  final String category;
  final WellnessSection section;
  final double lat;
  final double lng;
  final double distanceKm;

  LatLng get point => LatLng(lat, lng);

  String get distanceLabel => WellnessPlace.formatDistance(distanceKm);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapPlace &&
          id == other.id &&
          name == other.name &&
          emoji == other.emoji &&
          category == other.category &&
          section == other.section &&
          lat == other.lat &&
          lng == other.lng &&
          distanceKm == other.distanceKm;

  @override
  int get hashCode =>
      Object.hash(id, name, emoji, category, section, lat, lng, distanceKm);
}
