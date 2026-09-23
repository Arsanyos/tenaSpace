import 'package:flutter/material.dart';

import '../theme/tena_decorations.dart';
import '../theme/tena_text.dart';

/// White rounded card with an uppercase eyebrow title, used across the place
/// detail screen (`rounded-3xl border border-stone bg-white p-5 shadow-soft`).
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.eyebrow,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final String eyebrow;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: tenaCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: TenaText.eyebrow),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
