import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tena_colors.dart';
import '../../../../core/theme/tena_decorations.dart';
import '../../application/map_screen_controller.dart';
import 'map_frame.dart';
import 'wellness_map.dart';

/// Opens the expanded, interactive map in an Apple-style sheet
/// (`SheetModal` + `.apple-sheet` on the web).
Future<void> showWellnessMapSheet(
  BuildContext context, {
  String? focusPlaceId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: TenaColors.ink.withValues(alpha: 0.35),
    builder: (context) => WellnessMapSheet(focusPlaceId: focusPlaceId),
  );
}

class WellnessMapSheet extends ConsumerWidget {
  const WellnessMapSheet({super.key, this.focusPlaceId});

  final String? focusPlaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(filteredMapPlacesProvider);
    final highlighted = ref.watch(highlightedMapPlaceIdsProvider);
    final selectedId = ref.watch(
      mapScreenControllerProvider.select((state) => state.selectedId),
    );
    final mapHeight = math.min(MediaQuery.sizeOf(context).height * 0.68, 512.0);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF8).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(TenaRadii.card),
          border: Border.all(color: TenaColors.white.withValues(alpha: 0.65)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x59172132),
              offset: Offset(0, 32),
              blurRadius: 64,
              spreadRadius: -28,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wellness map',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: TenaColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Addis Ababa',
                          style: TextStyle(
                            fontSize: 14,
                            color: TenaColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CloseButton(onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: MapFrame(
                height: mapHeight,
                radius: 20,
                child: WellnessMap(
                  places: places,
                  highlightedIds: highlighted,
                  selectedId: selectedId ?? focusPlaceId,
                  onSelectPlace: ref
                      .read(mapScreenControllerProvider.notifier)
                      .select,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `.apple-icon-button`
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: Material(
        color: TenaColors.white.withValues(alpha: 0.72),
        shape: CircleBorder(
          side: BorderSide(color: TenaColors.white.withValues(alpha: 0.8)),
        ),
        elevation: 2,
        shadowColor: const Color(0x59172132),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Icon(Icons.close_rounded, size: 18, color: TenaColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
