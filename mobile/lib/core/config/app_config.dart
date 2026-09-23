import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build-time configuration injected with `--dart-define`.
///
/// ```sh
/// # Point the app at the Next.js server running on your machine
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
///
/// # Demo without any backend (bundled Addis Ababa feed, fallback audio)
/// flutter run --dart-define=USE_MOCK_API=true
/// ```
@immutable
final class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.useMockApi});

  factory AppConfig.fromEnvironment() {
    const rawBaseUrl = String.fromEnvironment('API_BASE_URL');
    const useMock = bool.fromEnvironment('USE_MOCK_API');

    return AppConfig(
      apiBaseUrl: rawBaseUrl.isEmpty
          ? defaultApiBaseUrl()
          : _stripTrailingSlash(rawBaseUrl),
      useMockApi: useMock,
    );
  }

  /// Origin of the Next.js app that hosts `/api/wellness-feed`,
  /// `/api/generate-sound` and the static `/audio/*.mp3` files.
  final String apiBaseUrl;

  /// When true, repositories are swapped for in-memory fakes so the app can be
  /// demoed with no server and no API keys.
  final bool useMockApi;

  /// Android emulators reach the host machine through `10.0.2.2`; iOS
  /// simulators, desktop and web share the host's loopback interface.
  static String defaultApiBaseUrl({TargetPlatform? platform, bool? isWeb}) {
    final onWeb = isWeb ?? kIsWeb;
    final target = platform ?? defaultTargetPlatform;
    if (!onWeb && target == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static String _stripTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
