import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

typedef GeneratedSound = ({Uint8List bytes, String contentType});

abstract interface class SoundRepository {
  /// Asks the backend to synthesise [durationSeconds] of audio for [prompt].
  Future<GeneratedSound> generateSound({
    required String prompt,
    required int durationSeconds,
  });
}

/// `POST /api/generate-sound` → Hugging Face AudioLDM2, proxied by Next.js so
/// the API key never ships inside the app binary.
final class ApiSoundRepository implements SoundRepository {
  const ApiSoundRepository(this._client);

  static const path = '/api/generate-sound';

  final ApiClient _client;

  @override
  Future<GeneratedSound> generateSound({
    required String prompt,
    required int durationSeconds,
  }) async {
    final response = await _client.postForBytes(path, {
      'prompt': prompt,
      'durationSeconds': durationSeconds,
    });
    if (response.bytes.isEmpty) {
      throw const ApiException('The audio provider returned an empty file.');
    }
    return (bytes: response.bytes, contentType: response.contentType);
  }
}

/// Mock mode has no AI backend, so it fails on purpose after a short delay;
/// the player then transparently falls back to the synthesised ambient loop.
final class MockSoundRepository implements SoundRepository {
  const MockSoundRepository({this.delay = const Duration(milliseconds: 1200)});

  final Duration delay;

  @override
  Future<GeneratedSound> generateSound({
    required String prompt,
    required int durationSeconds,
  }) async {
    await Future<void>.delayed(delay);
    throw const ApiException(
      'AI sound generation is unavailable in mock mode.',
    );
  }
}

final soundRepositoryProvider = Provider<SoundRepository>((ref) {
  if (ref.watch(appConfigProvider).useMockApi) {
    return const MockSoundRepository();
  }
  return ApiSoundRepository(ref.watch(apiClientProvider));
});
