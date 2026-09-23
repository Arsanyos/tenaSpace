import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tenaspace/core/network/api_client.dart';
import 'package:tenaspace/features/feed/domain/wellness_section.dart';
import 'package:tenaspace/features/place/application/bytes_audio_source.dart';
import 'package:tenaspace/features/place/application/sound_player_controller.dart';
import 'package:tenaspace/features/place/data/sound_repository.dart';
import 'package:tenaspace/features/place/domain/audio_config.dart';

import '../../../helpers/test_helpers.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class _FakeSoundRepository implements SoundRepository {
  _FakeSoundRepository({this.bytes, this.error});

  final Uint8List? bytes;
  final Object? error;
  int calls = 0;

  @override
  Future<GeneratedSound> generateSound({
    required String prompt,
    required int durationSeconds,
  }) async {
    calls++;
    if (error != null) throw error!;
    return (bytes: bytes!, contentType: 'audio/mpeg');
  }
}

const _aiConfig = ResolvedAudioConfig(
  base: AudioConfig(
    kind: AudioKind.walkingMix,
    label: 'Play AI walking soundscape',
    basePrompt: 'Walk.',
    durationSeconds: 35,
  ),
  prompt: 'Walk. Instrumental only, no vocals.',
);

const _staticConfig = ResolvedAudioConfig(
  base: AudioConfig(
    kind: AudioKind.meditation,
    label: 'Play calm background sound',
    basePrompt: 'Calm.',
    durationSeconds: 45,
    staticPath: '/audio/calm-meditation.mp3',
  ),
  prompt: 'Calm. Instrumental only, no vocals.',
);

void main() {
  setUpAll(() {
    registerFallbackValue(AudioSource.uri(Uri.parse('https://fallback.test')));
    registerFallbackValue(LoopMode.off);
  });

  late MockAudioPlayer player;

  setUp(() {
    player = MockAudioPlayer();
    when(() => player.setAudioSource(any())).thenAnswer((_) async => null);
    when(() => player.setLoopMode(any())).thenAnswer((_) async {});
    when(() => player.setVolume(any())).thenAnswer((_) async {});
    when(() => player.play()).thenAnswer((_) async {});
    when(() => player.pause()).thenAnswer((_) async {});
    when(() => player.dispose()).thenAnswer((_) async {});
  });

  Future<(SoundPlayerController, SoundPlayerState Function())> build(
    SoundRepository repository,
  ) async {
    final prefs = await fakePreferences();
    final container = createContainer(
      overrides: [
        ...baseOverrides(prefs),
        audioPlayerFactoryProvider.overrideWithValue(() => player),
        soundRepositoryProvider.overrideWithValue(repository),
      ],
    );
    final provider = soundPlayerControllerProvider('meskel-walk');
    container.listen(provider, (_, _) {});
    return (container.read(provider.notifier), () => container.read(provider));
  }

  group('SoundPlayerController', () {
    test('plays generated audio from memory and caches it', () async {
      final repository = _FakeSoundRepository(
        bytes: Uint8List.fromList([1, 2]),
      );
      final (controller, state) = await build(repository);

      await controller.start(_aiConfig);

      expect(state().status, SoundPlayerStatus.playing);
      expect(state().isFallbackTrack, isFalse);
      expect(state().errorMessage, isNull);

      final source = verify(() => player.setAudioSource(captureAny()))
          .captured
          .single;
      expect(source, isA<BytesAudioSource>());
      verify(() => player.setLoopMode(LoopMode.one)).called(1);
      verify(() => player.play()).called(1);

      // Second start replays from the session cache without another request.
      await controller.start(_aiConfig);
      expect(repository.calls, 1);
    });

    test('falls back to the synthesised loop when generation fails', () async {
      final repository = _FakeSoundRepository(
        error: const ApiException('HUGGINGFACE_API_KEY is not configured'),
      );
      final (controller, state) = await build(repository);

      await controller.start(_aiConfig);

      expect(state().status, SoundPlayerStatus.playing);
      expect(state().isFallbackTrack, isTrue);
      expect(state().errorMessage, 'HUGGINGFACE_API_KEY is not configured');

      final source =
          verify(() => player.setAudioSource(captureAny())).captured.single
              as BytesAudioSource;
      expect(source.contentType, 'audio/wav');
    });

    test('streams static tracks from the Next.js public folder', () async {
      final (controller, state) = await build(_FakeSoundRepository());

      await controller.start(_staticConfig);

      expect(state().status, SoundPlayerStatus.playing);
      final source =
          verify(() => player.setAudioSource(captureAny())).captured.single
              as UriAudioSource;
      expect(
        source.uri.toString(),
        '${testConfig.apiBaseUrl}/audio/calm-meditation.mp3',
      );
    });

    test(
      'reports an error (no fallback) when the static track fails',
      () async {
        when(() => player.setAudioSource(any()))
            .thenThrow(PlayerException(404, 'not found', null));
        final (controller, state) = await build(_FakeSoundRepository());

        await controller.start(_staticConfig);

        expect(state().status, SoundPlayerStatus.error);
        expect(state().errorMessage, 'Could not load the meditation track.');
      },
    );

    test('toggles pause/resume and clamps volume', () async {
      final repository = _FakeSoundRepository(bytes: Uint8List.fromList([1]));
      final (controller, state) = await build(repository);
      await controller.start(_aiConfig);

      await controller.togglePause();
      expect(state().status, SoundPlayerStatus.paused);
      verify(() => player.pause()).called(1);

      await controller.togglePause();
      expect(state().status, SoundPlayerStatus.playing);

      await controller.setVolume(1.7);
      expect(state().volume, 1.0);
      verify(() => player.setVolume(1.0)).called(1);
    });
  });
}
