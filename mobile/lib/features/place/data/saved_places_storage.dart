import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/shared_preferences_provider.dart';

/// Persists bookmarked place ids (web: `tenaspace-saved-place-ids`).
class SavedPlacesStorage {
  const SavedPlacesStorage(this._prefs);

  static const storageKey = 'tenaspace-saved-place-ids';

  final SharedPreferences _prefs;

  Set<String> load() => _prefs.getStringList(storageKey)?.toSet() ?? {};

  Future<void> save(Set<String> ids) =>
      _prefs.setStringList(storageKey, ids.toList());
}

final savedPlacesStorageProvider = Provider<SavedPlacesStorage>(
  (ref) => SavedPlacesStorage(ref.watch(sharedPreferencesProvider)),
);
