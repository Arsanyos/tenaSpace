import 'package:flutter/foundation.dart';

import 'suggested_action.dart';
import 'wellness_section.dart';

/// One curated Addis Ababa place as returned by `/api/wellness-feed`.
@immutable
final class WellnessPlace {
  const WellnessPlace({
    required this.id,
    required this.emoji,
    required this.name,
    required this.category,
    required this.distanceKm,
    required this.recommendation,
    required this.section,
    this.tags = const [],
    this.lat,
    this.lng,
    this.durationMinutes,
    this.bestTime,
    this.audioKind,
    this.suggestedActions = const [],
  });

  static const maxTags = 5;
  static const maxSuggestedActions = 4;

  /// Defensive parser mirroring `parsePlace` in `lib/get-wellness-feed.ts`:
  /// required fields must be present and non-blank, otherwise the place is
  /// dropped (returns `null`) instead of crashing the whole feed.
  static WellnessPlace? fromJson(
    Object? raw, {
    WellnessSection? fallbackSection,
  }) {
    if (raw is! Map) return null;

    final name = _readString(raw, 'name');
    final category = _readString(raw, 'category');
    final emoji = _readString(raw, 'emoji');
    final recommendation = _readString(raw, 'recommendation');
    final distanceKm = _readDouble(raw, 'distanceKm');
    final section =
        WellnessSection.fromWire(_readString(raw, 'section')) ??
        fallbackSection;

    if (name == null ||
        category == null ||
        emoji == null ||
        recommendation == null ||
        section == null ||
        distanceKm == null) {
      return null;
    }

    final tags = raw['tags'];
    final actions = raw['suggestedActions'];

    return WellnessPlace(
      id: _readString(raw, 'id') ?? slugify(name),
      emoji: emoji,
      name: name,
      category: category,
      distanceKm: distanceKm,
      recommendation: recommendation,
      section: section,
      tags: tags is List
          ? tags
                .whereType<String>()
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .take(maxTags)
                .toList()
          : const [],
      lat: _readDouble(raw, 'lat'),
      lng: _readDouble(raw, 'lng'),
      durationMinutes: _readDouble(raw, 'durationMinutes')?.round(),
      bestTime: _readString(raw, 'bestTime'),
      audioKind: AudioKind.fromWire(_readString(raw, 'audioKind')),
      suggestedActions: actions is List
          ? actions
                .map(SuggestedAction.fromJson)
                .whereType<SuggestedAction>()
                .take(maxSuggestedActions)
                .toList()
          : const [],
    );
  }

  final String id;
  final String emoji;
  final String name;
  final String category;
  final double distanceKm;
  final String recommendation;
  final WellnessSection section;
  final List<String> tags;
  final double? lat;
  final double? lng;
  final int? durationMinutes;
  final String? bestTime;
  final AudioKind? audioKind;
  final List<SuggestedAction> suggestedActions;

  bool get hasCoordinates => lat != null && lng != null;

  /// "1.8" or "2" — matches how JavaScript prints numbers on the web.
  String get distanceLabel => formatDistance(distanceKm);

  WellnessPlace copyWith({String? id}) => WellnessPlace(
    id: id ?? this.id,
    emoji: emoji,
    name: name,
    category: category,
    distanceKm: distanceKm,
    recommendation: recommendation,
    section: section,
    tags: tags,
    lat: lat,
    lng: lng,
    durationMinutes: durationMinutes,
    bestTime: bestTime,
    audioKind: audioKind,
    suggestedActions: suggestedActions,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'emoji': emoji,
    'name': name,
    'category': category,
    'distanceKm': distanceKm,
    'recommendation': recommendation,
    'section': section.wire,
    'tags': tags,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
    if (durationMinutes != null) 'durationMinutes': durationMinutes,
    if (bestTime != null) 'bestTime': bestTime,
    if (audioKind != null) 'audioKind': audioKind!.wire,
    'suggestedActions': suggestedActions.map((a) => a.toJson()).toList(),
  };

  static String formatDistance(double km) {
    if (km == km.roundToDouble()) return km.round().toString();
    return km.toStringAsFixed(1);
  }

  /// `slugifyId` from the server: lowercase, non-alphanumerics collapsed to
  /// dashes, trimmed, capped at 64 chars.
  static String slugify(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.length > 64 ? slug.substring(0, 64) : slug;
  }

  static String? _readString(Map<Object?, Object?> source, String key) {
    final value = source[key];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _readDouble(Map<Object?, Object?> source, String key) {
    final value = source[key];
    if (value is! num || !value.isFinite) return null;
    return value.toDouble();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WellnessPlace &&
          id == other.id &&
          emoji == other.emoji &&
          name == other.name &&
          category == other.category &&
          distanceKm == other.distanceKm &&
          recommendation == other.recommendation &&
          section == other.section &&
          listEquals(tags, other.tags) &&
          lat == other.lat &&
          lng == other.lng &&
          durationMinutes == other.durationMinutes &&
          bestTime == other.bestTime &&
          audioKind == other.audioKind &&
          listEquals(suggestedActions, other.suggestedActions);

  @override
  int get hashCode => Object.hash(
    id,
    emoji,
    name,
    category,
    distanceKm,
    recommendation,
    section,
    Object.hashAll(tags),
    lat,
    lng,
    durationMinutes,
    bestTime,
    audioKind,
    Object.hashAll(suggestedActions),
  );

  @override
  String toString() => 'WellnessPlace($id, $name)';
}
