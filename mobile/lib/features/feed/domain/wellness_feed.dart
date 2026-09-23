import 'package:flutter/foundation.dart';

import 'wellness_place.dart';
import 'wellness_section.dart';

@immutable
final class WellnessFeedSection {
  const WellnessFeedSection({
    required this.section,
    required this.title,
    required this.places,
  });

  final WellnessSection section;
  final String title;
  final List<WellnessPlace> places;

  Map<String, dynamic> toJson() => {
    'id': section.wire,
    'title': title,
    'places': places.map((place) => place.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessFeedSection &&
          section == other.section &&
          title == other.title &&
          listEquals(places, other.places);

  @override
  int get hashCode => Object.hash(section, title, Object.hashAll(places));
}

/// The personalised feed: one featured match plus the four ordered sections.
@immutable
final class WellnessFeed {
  const WellnessFeed({required this.featured, required this.sections});

  static const maxPlacesPerSection = 3;

  /// Mirrors `parseCuratedFeed` on the server: sections are always emitted in
  /// canonical order (empty when missing), capped to three places, and place
  /// ids are de-duplicated with a numeric suffix.
  static WellnessFeed? fromJson(Object? raw) {
    if (raw is! Map) return null;

    final featured = WellnessPlace.fromJson(raw['featured']);
    final sectionsRaw = raw['sections'];
    if (featured == null || sectionsRaw is! List) return null;

    final parsed = <WellnessSection, WellnessFeedSection>{};
    for (final sectionRaw in sectionsRaw) {
      if (sectionRaw is! Map) continue;
      final section = WellnessSection.fromWire(sectionRaw['id'] as String?);
      final placesRaw = sectionRaw['places'];
      if (section == null || placesRaw is! List) continue;

      final title = sectionRaw['title'];
      parsed[section] = WellnessFeedSection(
        section: section,
        title: title is String && title.trim().isNotEmpty
            ? title.trim()
            : section.defaultTitle,
        places: placesRaw
            .map(
              (place) =>
                  WellnessPlace.fromJson(place, fallbackSection: section),
            )
            .whereType<WellnessPlace>()
            .take(maxPlacesPerSection)
            .toList(),
      );
    }

    return WellnessFeed(
      featured: featured,
      sections: [
        for (final section in WellnessSection.values)
          _dedupe(
            parsed[section] ??
                WellnessFeedSection(
                  section: section,
                  title: section.defaultTitle,
                  places: const [],
                ),
          ),
      ],
    );
  }

  final WellnessPlace featured;
  final List<WellnessFeedSection> sections;

  bool get hasPlaces => sections.any((section) => section.places.isNotEmpty);

  /// Featured first, then every section place, unique by id.
  List<WellnessPlace> get allPlaces {
    final seen = <String>{};
    return [
      for (final place in [featured, ...sections.expand((s) => s.places)])
        if (seen.add(place.id)) place,
    ];
  }

  WellnessPlace? findPlace(String id) {
    if (featured.id == id) return featured;
    for (final section in sections) {
      for (final place in section.places) {
        if (place.id == id) return place;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'featured': featured.toJson(),
    'sections': sections.map((section) => section.toJson()).toList(),
  };

  static WellnessFeedSection _dedupe(WellnessFeedSection section) {
    final seen = <String>{};
    final places = <WellnessPlace>[];
    for (final place in section.places) {
      if (seen.add(place.id)) {
        places.add(place);
        continue;
      }
      final uniqueId = '${place.id}-${seen.length + 1}';
      seen.add(uniqueId);
      places.add(place.copyWith(id: uniqueId));
    }
    return WellnessFeedSection(
      section: section.section,
      title: section.title,
      places: places,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessFeed &&
          featured == other.featured &&
          listEquals(sections, other.sections);

  @override
  int get hashCode => Object.hash(featured, Object.hashAll(sections));
}
