import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/shared_preferences_provider.dart';
import '../domain/wellness_feed.dart';

/// Keeps the last curated feed on disk so the map and place-detail screens
/// can still resolve places after a cold start (the web used
/// `sessionStorage` for the same purpose).
class FeedCache {
  const FeedCache(this._prefs);

  static const storageKey = 'tenaspace-latest-curated-feed';

  final SharedPreferences _prefs;

  WellnessFeed? read() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return null;

    try {
      return WellnessFeed.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  Future<void> write(WellnessFeed feed) =>
      _prefs.setString(storageKey, jsonEncode(feed.toJson()));

  Future<void> clear() => _prefs.remove(storageKey);
}

final feedCacheProvider = Provider<FeedCache>(
  (ref) => FeedCache(ref.watch(sharedPreferencesProvider)),
);
