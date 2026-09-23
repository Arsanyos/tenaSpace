import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/tena_colors.dart';
import '../../../core/theme/tena_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/sunrise_surface.dart';
import '../application/feed_controller.dart';
import '../domain/wellness_feed.dart';
import 'widgets/wellness_place_card.dart';

/// Home tab: sunrise header + the curated feed (or its loading/empty states).
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: TenaColors.cream,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FeedHeader(
              status: switch (feed) {
                AsyncData() => 'Curated for your goals, interests, and mood.',
                AsyncError() => 'We could not load your curated plan.',
                _ => 'Groq is curating your places...',
              },
            ),
            Expanded(
              child: switch (feed) {
                AsyncData(:final value) => _FeedList(feed: value),
                AsyncError(:final error) => _EmptyState(
                  message: error.toString(),
                  onRetry: () =>
                      ref.read(feedControllerProvider.notifier).refresh(),
                ),
                _ => const _LoadingState(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return SunriseSurface(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selam 👋',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TenaColors.orangeSoft.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your wellness plan is ready',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: -0.6,
                  color: TenaColors.white,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: Text(
                  status,
                  key: ValueKey(status),
                  style: const TextStyle(fontSize: 14, color: TenaColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({required this.feed});

  final WellnessFeed feed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        WellnessPlaceCard(
          place: feed.featured,
          variant: WellnessPlaceCardVariant.featured,
          onViewDetails: () => context.push(AppRoutes.place(feed.featured.id)),
        ),
        const SizedBox(height: 32),
        for (final section in feed.sections)
          if (section.places.isNotEmpty) ...[
            Text(section.title, style: TenaText.sectionTitle),
            const SizedBox(height: 16),
            for (final place in section.places) ...[
              WellnessPlaceCard(
                place: place,
                onViewDetails: () => context.push(AppRoutes.place(place.id)),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
          ],
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'TenaSpace turns your city into a personalized wellness map.',
            textAlign: TextAlign.center,
            style: TenaText.caption,
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(height: 16),
            Text(
              'Curating your wellness feed...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TenaColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Column(
        children: [
          const Text('🌫️', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 16),
          const Text('No data to display', style: TenaText.sectionTitle),
          const SizedBox(height: 8),
          const Text(
            'Groq could not curate suggestions right now. Check the server '
            'and your API key, then try again.',
            textAlign: TextAlign.center,
            style: TenaText.caption,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: TenaColors.clay,
            ),
          ),
          const SizedBox(height: 24),
          PillButton(
            label: 'Try again',
            onPressed: onRetry,
            expand: false,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
