import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/network/api_client.dart';
import '../data/sound_repository.dart';
import '../domain/audio_config.dart';
import '../domain/fallback_ambient_wav.dart';
import 'bytes_audio_source.dart';

enum SoundPlayerStatus { idle, loading, playing, paused, error }

@immutable
final class SoundPlayerState {
  const SoundPlayerState({
    this.status = SoundPlayerStatus.idle,
    this.volume = 0.72,
    this.errorMessage,
    this.isFallbackTrack = false,
  });

  final SoundPlayerStatus status;
  final double volume;
  final String? errorMessage;

  /// True when the synthesised ambient loop is playing because generation
  /// failed — the UI labels the track honestly in that case.
  final bool isFallbackTrack;

  bool get isIdle => status == SoundPlayerStatus.idle;
  bool get isLoading => status == SoundPlayerStatus.loading;
  bool get isPlaying => status == SoundPlayerStatus.playing;
  bool get isPaused => status == SoundPlayerStatus.paused;
  bool get hasError => status == SoundPlayerStatus.error;

  /// The player card is shown once playback has been requested.
  bool get showsPlayer => isLoading || isPlaying || isPaused;

  SoundPlayerState copyWith({
    SoundPlayerStatus? status,
    double? volume,
    String? errorMessage,
    bool clearError = false,
    bool? isFallbackTrack,
  }) {
    return SoundPlayerState(
      status: status ?? this.status,
      volume: volume ?? this.volume,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFallbackTrack: isFallbackTrack ?? this.isFallbackTrack,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoundPlayerState &&
          status == other.status &&
          volume == other.volume &&
          errorMessage == other.errorMessage &&
          isFallbackTrack == other.isFallbackTrack;

  @override
  int get hashCode =>
      Object.hash(status, volume, errorMessage, isFallbackTrack);
}

/// What we remember about a place's audio for the rest of the session so a
/// second tap plays instantly (web: `SESSION_AUDIO_CACHE`).
sealed class CachedAudio {
  const CachedAudio();
}

final class CachedAudioUrl extends CachedAudio {
  const CachedAudioUrl(this.uri);
  final Uri uri;
}

final class CachedAudioBytes extends CachedAudio {
  const CachedAudioBytes(this.bytes, {required this.contentType});
  final Uint8List bytes;
  final String contentType;
}

/// App-lifetime cache keyed by place id.
final audioCacheProvider = Provider<Map<String, CachedAudio>>((ref) => {});

/// Indirection so tests can inject a mocked [AudioPlayer].
final audioPlayerFactoryProvider = Provider<AudioPlayer Function()>(
  (ref) => AudioPlayer.new,
);

/// Owns one [AudioPlayer] per place-detail screen. `autoDispose` means
/// leaving the screen tears the player down (the web did the same in a
/// `useEffect` cleanup).
///
/// Playback strategy, in order:
///  1. session cache → instant replay
///  2. static track streamed from the Next.js `public/audio` folder
///  3. AI generation via the backend, falling back to a synthesised loop
class SoundPlayerController extends Notifier<SoundPlayerState> {
  SoundPlayerController(this.placeId);

  final String placeId;

  late AudioPlayer _player;

  @override
  SoundPlayerState build() {
    _player = ref.watch(audioPlayerFactoryProvider)();
    ref.onDispose(_player.dispose);
    return const SoundPlayerState();
  }

  Future<void> start(ResolvedAudioConfig config) async {
    final cache = ref.read(audioCacheProvider);
    state = state.copyWith(
      status: SoundPlayerStatus.loading,
      clearError: true,
      isFallbackTrack: false,
    );

    final cached = cache[placeId];
    if (cached != null) {
      await _playCached(cached, loop: config.loop);
      return;
    }

    final staticPath = config.staticPath;
    if (staticPath != null) {
      final uri = ref.read(apiClientProvider).resolve(staticPath);
      try {
        await _play(AudioSource.uri(uri), loop: config.loop);
        cache[placeId] = CachedAudioUrl(uri);
      } on Exception {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: SoundPlayerStatus.error,
          errorMessage: 'Could not load the meditation track.',
        );
      }
      return;
    }

    try {
      final sound = await ref
          .read(soundRepositoryProvider)
          .generateSound(
            prompt: config.prompt,
            durationSeconds: config.durationSeconds,
          );
      if (!ref.mounted) return;

      cache[placeId] = CachedAudioBytes(
        sound.bytes,
        contentType: sound.contentType,
      );
      await _play(
        BytesAudioSource(sound.bytes, contentType: sound.contentType),
        loop: config.loop,
      );
    } on Exception catch (error) {
      if (!ref.mounted) return;
      final message = error is ApiException
          ? error.message
          : 'Could not generate sound';

      try {
        await _play(
          BytesAudioSource(buildFallbackAmbientWav(), contentType: 'audio/wav'),
          loop: true,
        );
        state = state.copyWith(errorMessage: message, isFallbackTrack: true);
      } on Exception {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: SoundPlayerStatus.error,
          errorMessage: message,
        );
      }
    }
  }

  Future<void> togglePause() async {
    switch (state.status) {
      case SoundPlayerStatus.playing:
        await _player.pause();
        if (ref.mounted) {
          state = state.copyWith(status: SoundPlayerStatus.paused);
        }
      case SoundPlayerStatus.paused:
        unawaited(_player.play());
        state = state.copyWith(status: SoundPlayerStatus.playing);
      case SoundPlayerStatus.idle:
      case SoundPlayerStatus.loading:
      case SoundPlayerStatus.error:
        return;
    }
  }

  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped);
    await _player.setVolume(clamped);
  }

  Future<void> _playCached(CachedAudio cached, {required bool loop}) {
    final source = switch (cached) {
      CachedAudioUrl(:final uri) => AudioSource.uri(uri),
      CachedAudioBytes(:final bytes, :final contentType) => BytesAudioSource(
        bytes,
        contentType: contentType,
      ),
    };
    return _play(source, loop: loop);
  }

  Future<void> _play(AudioSource source, {required bool loop}) async {
    await _player.setAudioSource(source);
    await _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);
    await _player.setVolume(state.volume);
    // `play()` only completes when playback stops, so it must not be awaited.
    unawaited(_player.play());
    if (ref.mounted) {
      state = state.copyWith(status: SoundPlayerStatus.playing);
    }
  }
}

final soundPlayerControllerProvider = NotifierProvider.autoDispose
    .family<SoundPlayerController, SoundPlayerState, String>(
      SoundPlayerController.new,
    );
