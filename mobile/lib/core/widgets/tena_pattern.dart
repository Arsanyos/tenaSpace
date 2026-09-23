import 'package:flutter/material.dart';

/// Subtle Ethiopian-inspired overlay ported from the `.tena-pattern` CSS:
/// two soft highlight dots plus a repeating 45° cross-hatch.
class TenaPattern extends StatelessWidget {
  const TenaPattern({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _TenaPatternPainter(), child: child);
  }
}

class _TenaPatternPainter extends CustomPainter {
  const _TenaPatternPainter();

  static const double _period = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final hatch = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 2;

    // Diagonal stripes sweep from the top-left corner to the bottom-right one.
    for (var offset = -size.height; offset < size.width; offset += _period) {
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset + size.height, size.height),
        hatch,
      );
    }

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.18),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.62),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
