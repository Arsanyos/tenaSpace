import 'package:flutter/material.dart';

import 'tena_colors.dart';

/// Text styles matching the Tailwind combinations used repeatedly on the web.
abstract final class TenaText {
  /// `text-xs font-black uppercase tracking-[0.14em] text-clay`
  static const eyebrow = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.7,
    color: TenaColors.clay,
  );

  /// `text-3xl font-black leading-tight text-ink`
  static const title = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    height: 1.15,
    letterSpacing: -0.6,
    color: TenaColors.ink,
  );

  /// `text-xl font-black text-ink`
  static const sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: TenaColors.ink,
  );

  /// `text-base leading-7 text-muted`
  static const body = TextStyle(
    fontSize: 16,
    height: 1.6,
    color: TenaColors.muted,
  );

  /// `text-sm text-muted`
  static const caption = TextStyle(
    fontSize: 14,
    height: 1.45,
    color: TenaColors.muted,
  );

  /// `text-xs font-bold text-clay` used on tag chips.
  static const tag = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: TenaColors.clay,
  );

  /// `text-lg font-black text-white` primary CTA label.
  static const cta = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    color: TenaColors.white,
  );
}
