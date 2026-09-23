import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/tena_colors.dart';
import '../../../core/theme/tena_decorations.dart';
import '../../../core/widgets/sunrise_surface.dart';
import '../../profile/application/profile_controller.dart';
import 'widgets/floating_pill.dart';

/// Landing screen: pitch + "Start Your Wellness Profile" / "Explore as Guest".
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  Future<void> _exploreAsGuest(BuildContext context, WidgetRef ref) async {
    await ref.read(profileControllerProvider.notifier).continueAsGuest();
    if (context.mounted) context.go(AppRoutes.preparing);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SunriseSurface(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 64,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandRow(),
                        const SizedBox(height: 40),
                        const Text(
                          'Your wellness,\nyour city,\nyour way.',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                            letterSpacing: -1.2,
                            color: TenaColors.white,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Discover courts, clinics, calm spaces, healthy meals, '
                          'and wellness experiences — personalized for you.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                            color: TenaColors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const _FloatingPillCloud(),
                        const SizedBox(height: 40),
                        Text(
                          'TenaSpace turns your city into a personalized wellness map.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: TenaColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _StartButton(
                          onPressed: () => context.push(AppRoutes.onboarding),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => _exploreAsGuest(context, ref),
                          style: TextButton.styleFrom(
                            foregroundColor: TenaColors.white.withValues(
                              alpha: 0.8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Explore as Guest'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TenaColors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: TenaShadows.soft,
          ),
          child: const Text('🌅', style: TextStyle(fontSize: 18, height: 1)),
        ),
        const SizedBox(width: 16),
        const Text(
          'TenaSpace',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: TenaColors.white,
          ),
        ),
      ],
    );
  }
}

/// Four rotated example pills scattered like the web hero.
class _FloatingPillCloud extends StatelessWidget {
  const _FloatingPillCloud();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: FloatingPill(
              emoji: '🏀',
              title: 'Basketball Court',
              text: '1.8 km · Bole',
              rotationDegrees: -7,
            ),
          ),
          Positioned(
            right: 0,
            top: 56,
            child: FloatingPill(
              emoji: '🥗',
              title: 'Healthy Restaurant',
              text: 'Diabetic-friendly',
              rotationDegrees: 5,
            ),
          ),
          Positioned(
            left: 20,
            top: 152,
            child: FloatingPill(
              emoji: '🧘',
              title: 'Meditation Space',
              text: 'Entoto · Quiet',
              rotationDegrees: -3,
            ),
          ),
          Positioned(
            right: 4,
            top: 222,
            child: FloatingPill(
              emoji: '🏥',
              title: 'Clinic Nearby',
              text: 'Megenagna · 1.5 km',
              rotationDegrees: 3,
            ),
          ),
        ],
      ),
    );
  }
}

/// `.cta-start-btn`: solid white resting state, warm shadow, ink label.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TenaRadii.pill),
        boxShadow: TenaShadows.lift,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: TenaColors.white,
          foregroundColor: TenaColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        child: const Text('Start Your Wellness Profile'),
      ),
    );
  }
}
