import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SharedPreferences] is asynchronous to obtain, so `main()` awaits it once
/// and injects the instance through a `ProviderScope` override. Reading the
/// provider without that override is a programming error.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope.',
  );
});
