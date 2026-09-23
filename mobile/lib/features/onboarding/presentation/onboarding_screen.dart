import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/tena_colors.dart';
import '../../../core/theme/tena_decorations.dart';
import '../../../core/theme/tena_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../profile/application/profile_controller.dart';
import '../application/onboarding_controller.dart';
import 'widgets/selectable_card.dart';

/// 4-step profile builder (goals → lifestyle → diet → mood).
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  void _handleBack(BuildContext context, WidgetRef ref) {
    final wentBack = ref.read(onboardingControllerProvider.notifier).back();
    if (!wentBack) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.splash);
      }
    }
  }

  Future<void> _handleContinue(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(onboardingControllerProvider.notifier);
    if (controller.next()) return;

    // Last step: commit the draft, then hand over to the transition screen,
    // which pre-warms the feed while it animates.
    final draft = ref.read(onboardingControllerProvider).draft;
    await ref.read(profileControllerProvider.notifier).commit(draft);
    if (context.mounted) context.go(AppRoutes.preparing);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final content = state.content;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: state.isFirstStep,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.back();
        },
        child: Scaffold(
          backgroundColor: TenaColors.cream,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepHeader(
                  step: state.step,
                  stepCount: OnboardingState.stepCount,
                  progress: state.progress,
                  onBack: () => _handleBack(context, ref),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: ListView(
                      key: ValueKey(state.step),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      children: [
                        Text(
                          content.eyebrow.toUpperCase(),
                          style: TenaText.eyebrow,
                        ),
                        const SizedBox(height: 12),
                        Text(content.title, style: TenaText.title),
                        const SizedBox(height: 12),
                        Text(content.subtitle, style: TenaText.body),
                        const SizedBox(height: 20),
                        for (final option in content.options) ...[
                          SelectableCard(
                            emoji: option.emoji,
                            label: option.label,
                            selected: state.isSelected(option),
                            onTap: () => controller.toggle(option),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
                _StepFooter(
                  label: state.isLastStep
                      ? 'Create My Wellness Map'
                      : 'Continue',
                  onPressed: state.canContinue
                      ? () => _handleContinue(context, ref)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.stepCount,
    required this.progress,
    required this.onBack,
  });

  final int step;
  final int stepCount;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: TenaColors.cream,
        border: Border(
          bottom: BorderSide(color: TenaColors.stone.withValues(alpha: 0.8)),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'Step ${step + 1} of $stepCount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TenaColors.muted,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: 'Go back. Current step is ${step + 1} of $stepCount.',
                  child: Material(
                    color: TenaColors.orangeSoft,
                    shape: const CircleBorder(),
                    shadowColor: const Color(0x47502C19),
                    elevation: 3,
                    child: InkWell(
                      onTap: onBack,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: TenaColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(TenaRadii.pill),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: TenaColors.chip),
                  ),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: TenaColors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ),
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

class _StepFooter extends StatelessWidget {
  const _StepFooter({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TenaColors.white,
        border: Border(top: BorderSide(color: TenaColors.stone)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: PillButton(label: label, onPressed: onPressed),
        ),
      ),
    );
  }
}
