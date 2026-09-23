import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tena_colors.dart';
import '../../../../core/theme/tena_decorations.dart';
import '../../application/sound_player_controller.dart';
import '../../domain/audio_config.dart';

/// Glass-style background sound player (port of `ai-sound-player.tsx`).
///
/// Idle/error → a tappable card describing the sound.
/// Loading/playing/paused → play-pause button, track title, animated wave
/// bars and a volume slider.
class AiSoundPlayer extends ConsumerWidget {
  const AiSoundPlayer({super.key, required this.placeId, required this.config});

  final String placeId;
  final ResolvedAudioConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = soundPlayerControllerProvider(placeId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      child: state.showsPlayer
          ? _PlayerCard(
              key: const ValueKey('player'),
              state: state,
              config: config,
              onTogglePause: controller.togglePause,
              onVolumeChanged: controller.setVolume,
            )
          : _IdleCard(
              key: const ValueKey('idle'),
              config: config,
              errorMessage: state.errorMessage,
              onTap: () => controller.start(config),
            ),
    );
  }
}

class _IdleCard extends StatelessWidget {
  const _IdleCard({
    super.key,
    required this.config,
    required this.errorMessage,
    required this.onTap,
  });

  final ResolvedAudioConfig config;
  final String? errorMessage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: config.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: _glassDecoration(radius: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.isStatic ? 'BACKGROUND SOUND' : 'AI SOUND',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6,
                    color: TenaColors.clay.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  config.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: TenaColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.isStatic
                      ? 'Curated meditation music for this place.'
                      : 'Generated for your activity and mood.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: TenaColors.muted,
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: TenaColors.clay,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    super.key,
    required this.state,
    required this.config,
    required this.onTogglePause,
    required this.onVolumeChanged,
  });

  final SoundPlayerState state;
  final ResolvedAudioConfig config;
  final VoidCallback onTogglePause;
  final ValueChanged<double> onVolumeChanged;

  String get _title {
    if (state.isFallbackTrack) return 'Fallback ambient track';
    return config.isStatic
        ? 'Meditation soundtrack'
        : 'AI-generated soundscape';
  }

  String get _subtitle {
    if (state.isLoading) {
      return config.isStatic
          ? 'Loading soundtrack...'
          : 'Composing your sound...';
    }
    return state.isFallbackTrack
        ? 'Playing local fallback loop'
        : 'Looping in the background';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 14),
      decoration: _glassDecoration(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlayButton(state: state, onPressed: onTogglePause),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: TenaColors.ink,
                      ),
                    ),
                    Text(
                      _subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: TenaColors.muted,
                      ),
                    ),
                    if (state.isPlaying || state.isPaused) ...[
                      const SizedBox(height: 4),
                      _WaveBars(animating: state.isPlaying),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.volume_up_rounded,
                size: 16,
                color: TenaColors.muted.withValues(alpha: 0.8),
              ),
              Expanded(
                child: Semantics(
                  label: 'Volume',
                  child: Slider(
                    value: state.volume,
                    onChanged: onVolumeChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.state, required this.onPressed});

  final SoundPlayerState state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final loading = state.isLoading;

    return Semantics(
      button: true,
      enabled: !loading,
      label: state.isPlaying ? 'Pause sound' : 'Resume sound',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: loading ? 0.75 : 1,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: TenaGradients.playButton,
            border: Border.all(color: TenaColors.white.withValues(alpha: 0.85)),
            boxShadow: TenaShadows.orangeGlow,
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: loading ? null : onPressed,
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.25,
                          color: TenaColors.white,
                        ),
                      )
                    : Icon(
                        state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 26,
                        color: TenaColors.white,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Four bouncing bars (`.apple-audio-waves`); frozen and dimmed when paused.
class _WaveBars extends StatefulWidget {
  const _WaveBars({required this.animating});

  final bool animating;

  @override
  State<_WaveBars> createState() => _WaveBarsState();
}

class _WaveBarsState extends State<_WaveBars>
    with SingleTickerProviderStateMixin {
  static const _heights = [7.0, 14.0, 10.0, 16.0];
  static const _delays = [0.0, 0.15, 0.3, 0.45];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _WaveBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animating != widget.animating) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.animating) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.animating ? 0.85 : 0.45,
        child: SizedBox(
          height: 20,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _heights.length; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    _bar(i),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _bar(int index) {
    // scaleY oscillates 0.55 → 1 → 0.55 per cycle, offset per bar.
    final phase = (_controller.value - _delays[index] / 1.1) % 1;
    final scale = 0.55 + 0.45 * (0.5 - 0.5 * math.cos(2 * math.pi * phase));
    return Container(
      width: 3,
      height: _heights[index] * scale,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF985F), Color(0xFFF5783F)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
    );
  }
}

BoxDecoration _glassDecoration({required double radius}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: TenaColors.white.withValues(alpha: 0.72)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        TenaColors.white.withValues(alpha: 0.82),
        const Color(0xFFFFF8F0).withValues(alpha: 0.58),
      ],
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x47172132),
        offset: Offset(0, 20),
        blurRadius: 44,
        spreadRadius: -22,
      ),
    ],
  );
}
