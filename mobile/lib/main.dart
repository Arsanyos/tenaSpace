import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/storage/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Failed providers surface an explicit "Try again" in the UI instead of
      // Riverpod's default exponential-backoff retry.
      retry: (retryCount, error) => null,
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const TenaSpaceApp(),
    ),
  );
}
