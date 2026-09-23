import 'package:flutter/material.dart';

import '../theme/tena_decorations.dart';
import 'tena_pattern.dart';

/// The `bg-sunrise tena-pattern` combo: warm gradient, radial highlight and
/// the decorative cross-hatch, with [child] painted on top.
class SunriseSurface extends StatelessWidget {
  const SunriseSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: TenaGradients.sunrise),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: TenaGradients.sunriseHighlight,
        ),
        child: TenaPattern(
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
