import 'package:flutter/material.dart';

import '../theme/tena_colors.dart';
import '../theme/tena_decorations.dart';
import '../theme/tena_text.dart';

/// Full-width rounded CTA used by onboarding and empty states.
///
/// Passing `null` for [onPressed] renders the muted disabled look
/// (`bg-[#f8c3ad] cursor-not-allowed`) from the web.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = TenaColors.orange,
    this.foregroundColor = TenaColors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    this.textStyle,
    this.shadows = TenaShadows.soft,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final List<BoxShadow> shadows;

  /// Fill the available width (default) or shrink-wrap the label.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final style = (textStyle ?? TenaText.cta).copyWith(color: foregroundColor);

    return Semantics(
      button: true,
      enabled: enabled,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: enabled ? backgroundColor : TenaColors.orangeDisabled,
          borderRadius: BorderRadius.circular(TenaRadii.pill),
          boxShadow: enabled ? shadows : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(TenaRadii.pill),
            child: Padding(
              padding: padding,
              child: Center(
                widthFactor: expand ? null : 1,
                child: Text(label, style: style, textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
