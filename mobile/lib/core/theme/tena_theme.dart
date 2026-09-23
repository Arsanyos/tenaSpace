import 'package:flutter/material.dart';

import 'tena_colors.dart';
import 'tena_decorations.dart';

/// Builds the Material 3 theme that carries the TenaSpace design tokens.
///
/// Components mostly paint their own colors via [TenaColors], so the theme
/// focuses on the defaults that leak through (scaffold, text, sliders, sheets).
ThemeData buildTenaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: TenaColors.orange,
  );

  final colorScheme = base.colorScheme.copyWith(
    primary: TenaColors.orange,
    onPrimary: TenaColors.white,
    secondary: TenaColors.sage,
    surface: TenaColors.cream,
    onSurface: TenaColors.ink,
    outline: TenaColors.stone,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: TenaColors.cream,
    splashFactory: InkSparkle.splashFactory,
    textTheme: base.textTheme.apply(
      bodyColor: TenaColors.ink,
      displayColor: TenaColors.ink,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: TenaColors.orange,
      inactiveTrackColor: TenaColors.ink.withValues(alpha: 0.12),
      thumbColor: TenaColors.white,
      overlayColor: TenaColors.orange.withValues(alpha: 0.12),
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 8,
        elevation: 2,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: TenaColors.ink,
      contentTextStyle: const TextStyle(
        color: TenaColors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TenaRadii.md),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: TenaColors.orange,
    ),
  );
}
