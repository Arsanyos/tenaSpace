import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override, ProviderBase;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenaspace/core/config/app_config.dart';
import 'package:tenaspace/core/storage/shared_preferences_provider.dart';

/// A [ProviderContainer] with Riverpod's automatic retry disabled (so failing
/// providers settle immediately) that is disposed when the test ends.
ProviderContainer createContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(
    overrides: overrides,
    retry: (retryCount, error) => null,
  );
  addTearDown(container.dispose);
  return container;
}

/// In-memory [SharedPreferences] seeded with [values].
Future<SharedPreferences> fakePreferences([
  Map<String, Object> values = const {},
]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

const testConfig = AppConfig(
  apiBaseUrl: 'http://tenaspace.test',
  useMockApi: false,
);

/// Standard overrides every test needs: storage + config.
List<Override> baseOverrides(SharedPreferences prefs) => [
  sharedPreferencesProvider.overrideWithValue(prefs),
  appConfigProvider.overrideWithValue(testConfig),
];

/// Wraps [child] in a `ProviderScope` + `MaterialApp` for widget tests.
Widget wrapForTest(Widget child, {required List<Override> overrides}) {
  return ProviderScope(
    retry: (retryCount, error) => null,
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

/// Waits for an async provider to leave its loading state.
Future<void> settle(
  ProviderContainer container,
  ProviderBase<Object?> provider,
) async {
  // Keep the provider alive for the duration of the await.
  final subscription = container.listen(provider, (_, _) {});
  addTearDown(subscription.close);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

/// UTF-8 encoded JSON response (the default `http.Response` is Latin-1, which
/// cannot carry the emoji the feed is full of).
http.Response jsonResponse(Object body, {int status = 200}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

/// Sizes the test surface like a phone so full-screen layouts are reachable.
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls the first [Scrollable] until [text] is visible, then taps it.
Future<void> scrollAndTapText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
