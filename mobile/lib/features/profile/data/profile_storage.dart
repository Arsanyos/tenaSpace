import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/shared_preferences_provider.dart';
import '../domain/wellness_profile.dart';

/// Persists the committed profile — the mobile counterpart of
/// `lib/wellness-profile-storage.ts` (which used `localStorage`).
class ProfileStorage {
  const ProfileStorage(this._prefs);

  static const storageKey = 'tenaspace-wellness-profile';

  final SharedPreferences _prefs;

  WellnessProfile load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null) return WellnessProfile.empty;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return WellnessProfile.empty;
      return WellnessProfile.fromJson(decoded);
    } on FormatException {
      return WellnessProfile.empty;
    }
  }

  Future<void> save(WellnessProfile profile) =>
      _prefs.setString(storageKey, jsonEncode(profile.toJson()));

  Future<void> clear() => _prefs.remove(storageKey);
}

final profileStorageProvider = Provider<ProfileStorage>(
  (ref) => ProfileStorage(ref.watch(sharedPreferencesProvider)),
);
