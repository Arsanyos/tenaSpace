import 'package:flutter/material.dart';

import 'tena_colors.dart';

/// Corner radii mirroring the Tailwind scale used on the web
/// (`rounded-2xl`, `rounded-3xl`, `rounded-[1.8rem]`).
abstract final class TenaRadii {
  static const double md = 16;
  static const double lg = 24;
  static const double card = 28;
  static const double pill = 999;
}

/// Box shadows ported from `shadow-soft` / `shadow-lift`
/// (`rgba(80, 44, 25, x)` is the warm brown base color).
abstract final class TenaShadows {
  static const soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x47502C19),
      offset: Offset(0, 8),
      blurRadius: 22,
      spreadRadius: -14,
    ),
  ];

  static const lift = <BoxShadow>[
    BoxShadow(
      color: Color(0x6B502C19),
      offset: Offset(0, 18),
      blurRadius: 42,
      spreadRadius: -26,
    ),
  ];

  static const orangeGlow = <BoxShadow>[
    BoxShadow(
      color: Color(0xA6F5783F),
      offset: Offset(0, 10),
      blurRadius: 24,
      spreadRadius: -8,
    ),
  ];
}

/// Gradients ported from the `bg-sunrise` utility and the audio play button.
abstract final class TenaGradients {
  /// `linear-gradient(150deg, #ffd98f 0%, #ff985f 48%, #cf6448 100%)`
  static const sunrise = LinearGradient(
    begin: Alignment(-0.5, -0.87),
    end: Alignment(0.5, 0.87),
    colors: [Color(0xFFFFD98F), Color(0xFFFF985F), Color(0xFFCF6448)],
    stops: [0, 0.48, 1],
  );

  /// `radial-gradient(circle at 20% 10%, rgba(255,234,178,.75), transparent 28%)`
  static const sunriseHighlight = RadialGradient(
    center: Alignment(-0.6, -0.8),
    radius: 0.7,
    colors: [Color(0xBFFFEAB2), Color(0x00FFEAB2)],
  );

  /// `.apple-audio-play` background.
  static const playButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A5C), Color(0xFFF5783F), Color(0xFFE06438)],
    stops: [0, 0.52, 1],
  );

  /// `.transition-screen` backdrop.
  static const transition = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: [Color(0xFFFFF6EC), Color(0xFFFFD9BF), Color(0xFFFFC2A3)],
    stops: [0, 0.48, 1],
  );
}

/// Reusable card decoration: white surface, 1px stone ring, soft shadow.
BoxDecoration tenaCardDecoration({
  double radius = TenaRadii.lg,
  List<BoxShadow> shadows = TenaShadows.soft,
  Color color = TenaColors.white,
  Color borderColor = TenaColors.stone,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor),
    boxShadow: shadows,
  );
}
