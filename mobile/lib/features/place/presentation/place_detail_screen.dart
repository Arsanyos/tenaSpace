import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/tena_colors.dart';
import '../../../core/theme/tena_text.dart';
import '../../../core/widgets/emoji_badge.dart';
import '../../../core/widgets/glass_pill_button.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/sunrise_surface.dart';
import '../../../core/widgets/tag_chip.dart';
import '../../feed/application/feed_controller.dart';
import '../../feed/domain/suggested_action.dart';
import '../../map/presentation/widgets/map_frame.dart';
import '../../map/presentation/widgets/wellness_map.dart';
import '../application/place_detail_provider.dart';
import '../application/saved_places_controller.dart';
import '../domain/place_detail.dart';
import 'widgets/ai_sound_player.dart';
import 'widgets/suggested_action_tile.dart';

/// `/place/:id` — why it was recommended, where it is, and what to do there.
class PlaceDetailScreen extends ConsumerWidget {
  const PlaceDetailScreen({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(placeDetailProvider(placeId));
    final feedLoading = ref.watch(
      feedControllerProvider.select((feed) => feed.isLoading),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: TenaColors.cream,
        body: switch (detail) {
          final PlaceDetail detail => _DetailBody(detail: detail),
          null when feedLoading => const _LoadingBody(),
          null => const _NotFoundBody(),
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.detail});

  final PlaceDetail detail;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.feed);
    }
  }

  Future<void> _openDirections(BuildContext context) async {
    final uri = detail.directionsUri;
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      _notify(context, 'Could not open Google Maps on this device.');
    }
  }

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    SuggestedAction action,
  ) {
    switch (action.type) {
      case SuggestedActionType.directions:
        _openDirections(context);
      case SuggestedActionType.save:
        ref.read(savedPlacesControllerProvider.notifier).toggle(detail.id);
      case SuggestedActionType.audio:
        _notify(context, 'Use the sound player below to start playback.');
      case SuggestedActionType.breathing:
      case SuggestedActionType.timer:
      case SuggestedActionType.checklist:
      case SuggestedActionType.note:
      case SuggestedActionType.call:
      case SuggestedActionType.menu:
        _notify(context, '"${action.label}" is coming soon to TenaSpace.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(isPlaceSavedProvider(detail.id));
    final mapPlace = detail.mapPlace;
    final audio = detail.audioConfig;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SunriseSurface(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassPillButton(
                        label: 'Back',
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => _goBack(context),
                      ),
                      GlassPillButton(
                        label: saved ? 'Saved' : 'Save',
                        icon: saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        filled: saved,
                        onPressed: () => ref
                            .read(savedPlacesControllerProvider.notifier)
                            .toggle(detail.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmojiBadge(
                        emoji: detail.emoji,
                        size: 64,
                        color: TenaColors.white.withValues(alpha: 0.25),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                letterSpacing: -0.5,
                                color: TenaColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${detail.category} · ${detail.distanceLabel} km away',
                              style: TextStyle(
                                fontSize: 14,
                                color: TenaColors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              InfoCard(
                eyebrow: 'Why recommended',
                child: Text(
                  detail.whyRecommended,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: TenaColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InfoCard(
                eyebrow: 'Map location',
                padding: const EdgeInsets.all(16),
                child: mapPlace != null
                    ? MapFrame(
                        height: 208,
                        child: IgnorePointer(
                          child: WellnessMap(
                            places: [mapPlace],
                            highlightedIds: {mapPlace.id},
                            interactive: false,
                            showZoomControls: false,
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: TenaColors.chip,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Map coordinates are not available for this place yet.',
                          textAlign: TextAlign.center,
                          style: TenaText.caption,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              InfoCard(
                eyebrow: 'Visit snapshot',
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SnapshotRow(
                      icon: Icons.schedule_rounded,
                      text: detail.durationMinutes != null
                          ? '${detail.durationMinutes} min estimated walk'
                          : 'Duration not available',
                    ),
                    const SizedBox(height: 12),
                    _SnapshotRow(
                      icon: Icons.auto_awesome_rounded,
                      text: detail.bestTime != null
                          ? 'Best time: ${detail.bestTime}'
                          : 'Open recommendation anytime',
                    ),
                    const SizedBox(height: 12),
                    _SnapshotRow(
                      icon: Icons.pin_drop_outlined,
                      text: mapPlace != null
                          ? '${mapPlace.lat.toStringAsFixed(4)}, '
                                '${mapPlace.lng.toStringAsFixed(4)}'
                          : 'Coordinates unavailable',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InfoCard(
                eyebrow: 'Suggested actions',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final action in detail.renderedActions) ...[
                      SuggestedActionTile(
                        action: action,
                        onTap: () => _handleAction(context, ref, action),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (audio != null)
                      AiSoundPlayer(placeId: detail.id, config: audio),
                  ],
                ),
              ),
              if (detail.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final tag in detail.tags) TagChip(tag)],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: TenaColors.orange),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: TenaColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Loading place details...',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: TenaColors.muted,
        ),
      ),
    );
  }
}

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Place not found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: TenaColors.ink,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We could not find that place in your wellness feed. Try opening '
                'details from the home cards again.',
                textAlign: TextAlign.center,
                style: TenaText.caption,
              ),
              const SizedBox(height: 16),
              PillButton(
                label: '←  Back to feed',
                expand: false,
                onPressed: () => context.go(AppRoutes.feed),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
