import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/tena_colors.dart';
import '../../../core/theme/tena_decorations.dart';
import '../../feed/application/feed_controller.dart';

/// "Building your wellness map" interstitial shown for ~1.1 s between
/// onboarding and the feed. Reading [feedControllerProvider] here kicks off
/// the Groq call early — the Flutter equivalent of `router.prefetch("/feed")`.
class TransitionScreen extends ConsumerStatefulWidget {
  const TransitionScreen({
    super.key,
    this.title = 'Building your wellness map',
    this.subtitle = 'Personalizing places around you…',
    this.holdDuration = const Duration(milliseconds: 1100),
  });

  final String title;
  final String subtitle;
  final Duration holdDuration;

  @override
  ConsumerState<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends ConsumerState<TransitionScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    ref.read(feedControllerProvider);
    _timer = Timer(widget.holdDuration, () {
      if (mounted) context.go(AppRoutes.feed);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Semantics(
          liveRegion: true,
          label: '${widget.title}. ${widget.subtitle}',
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: TenaGradients.transition),
            child: Stack(
              children: [
                const _Orb(
                  alignment: Alignment(-1.3, -1.2),
                  size: 340,
                  color: Color(0xE6FF985F),
                ),
                const _Orb(
                  alignment: Alignment(1.4, 1.2),
                  size: 400,
                  color: Color(0xBFF5783F),
                ),
                const _Orb(
                  alignment: Alignment(0.2, 0.3),
                  size: 280,
                  color: Color(0xE6FFD6BD),
                ),
                Center(
                  child: _TransitionCard(
                    title: widget.title,
                    subtitle: widget.subtitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
              stops: const [0, 0.7],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransitionCard extends StatefulWidget {
  const _TransitionCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<_TransitionCard> createState() => _TransitionCardState();
}

class _TransitionCardState extends State<_TransitionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      constraints: const BoxConstraints(maxWidth: 384),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: TenaColors.white.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6678391C),
            offset: Offset(0, 32),
            blurRadius: 64,
            spreadRadius: -28,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  TenaColors.white.withValues(alpha: 0.85),
                  const Color(0xFFFFE9D7).withValues(alpha: 0.7),
                ],
              ),
              border: Border.all(
                color: TenaColors.white.withValues(alpha: 0.8),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x8078391C),
                  offset: Offset(0, 14),
                  blurRadius: 30,
                  spreadRadius: -16,
                ),
              ],
            ),
            child: const Text('🌅', style: TextStyle(fontSize: 30, height: 1)),
          ),
          const SizedBox(height: 20),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: TenaColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: TenaColors.muted),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(TenaRadii.pill),
            child: SizedBox(
              width: 160,
              height: 6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: TenaColors.orange.withValues(alpha: 0.16),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      // Slides a 40%-wide bar from -120% to +320%, like the CSS.
                      final dx = -1.2 + _controller.value * 4.4;
                      return FractionalTranslation(
                        translation: Offset(dx, 0),
                        child: const FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF985F), Color(0xFFF5783F)],
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
