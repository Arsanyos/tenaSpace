import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tena_colors.dart';
import '../../../core/theme/tena_decorations.dart';
import '../../../core/theme/tena_text.dart';
import '../../feed/application/feed_controller.dart';
import '../../feed/domain/wellness_section.dart';
import '../application/map_screen_controller.dart';
import '../domain/map_place.dart';
import 'widgets/map_frame.dart';
import 'widgets/map_sheet.dart';
import 'widgets/wellness_map.dart';

/// Map tab: section filters, a static preview that expands into a full
/// interactive sheet, and the "Nearby" list.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  void _openSheet(BuildContext context, {String? focusId}) {
    showWellnessMapSheet(context, focusPlaceId: focusId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapScreenControllerProvider);
    final controller = ref.read(mapScreenControllerProvider.notifier);
    final places = ref.watch(filteredMapPlacesProvider);
    final highlighted = ref.watch(highlightedMapPlaceIdsProvider);
    final feedLoading = ref.watch(
      feedControllerProvider.select((feed) => feed.isLoading),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: TenaColors.cream,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MapHeader(
              filter: state.filter,
              onFilterChanged: controller.setFilter,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _MapPreview(
                places: places,
                highlightedIds: highlighted,
                onTap: () => _openSheet(context),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: TenaColors.white.withValues(alpha: 0.9),
                  border: const Border(
                    top: BorderSide(color: TenaColors.stone),
                  ),
                ),
                child: _NearbyList(
                  places: places,
                  highlightedIds: highlighted,
                  selectedId: state.selectedId,
                  loading: feedLoading && places.isEmpty,
                  onSelect: (id) {
                    controller.select(id);
                    _openSheet(context, focusId: id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.filter, required this.onFilterChanged});

  final WellnessSection? filter;
  final ValueChanged<WellnessSection?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TenaColors.white.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: TenaColors.stone)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Wellness map', style: TenaText.sectionTitle),
              const SizedBox(height: 4),
              const Text(
                'Explore places across Addis Ababa',
                style: TenaText.caption,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: filter == null,
                    onTap: () => onFilterChanged(null),
                  ),
                  for (final section in WellnessSection.values)
                    _FilterChip(
                      label: section.filterLabel,
                      selected: filter == section,
                      onTap: () => onFilterChanged(section),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? TenaColors.orange : TenaColors.chip,
        borderRadius: BorderRadius.circular(TenaRadii.pill),
        elevation: selected ? 2 : 0,
        shadowColor: const Color(0x47502C19),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TenaRadii.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? TenaColors.white : TenaColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.places,
    required this.highlightedIds,
    required this.onTap,
  });

  final List<MapPlace> places;
  final Set<String> highlightedIds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open full screen map',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            MapFrame(
              height: 184,
              child: IgnorePointer(
                child: WellnessMap(
                  places: places,
                  highlightedIds: highlightedIds,
                  interactive: false,
                  showZoomControls: false,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: TenaColors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(TenaRadii.pill),
                  border: Border.all(
                    color: TenaColors.white.withValues(alpha: 0.9),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66172132),
                      offset: Offset(0, 10),
                      blurRadius: 24,
                      spreadRadius: -14,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_full_rounded,
                      size: 14,
                      color: TenaColors.ink,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Tap to expand',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TenaColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyList extends StatelessWidget {
  const _NearbyList({
    required this.places,
    required this.highlightedIds,
    required this.selectedId,
    required this.loading,
    required this.onSelect,
  });

  final List<MapPlace> places;
  final Set<String> highlightedIds;
  final String? selectedId;
  final bool loading;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('NEARBY', style: TenaText.eyebrow),
        const SizedBox(height: 12),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          )
        else if (places.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No places with map coordinates yet. Curate your feed from the '
              'Home tab and they will appear here.',
              textAlign: TextAlign.center,
              style: TenaText.caption,
            ),
          )
        else
          for (final place in places) ...[
            _NearbyTile(
              place: place,
              highlighted: highlightedIds.contains(place.id),
              selected: place.id == selectedId,
              onTap: () => onSelect(place.id),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _NearbyTile extends StatelessWidget {
  const _NearbyTile({
    required this.place,
    required this.highlighted,
    required this.selected,
    required this.onTap,
  });

  final MapPlace place;
  final bool highlighted;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TenaColors.orangeSoft : TenaColors.white,
      borderRadius: BorderRadius.circular(TenaRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TenaRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TenaRadii.md),
            border: Border.all(
              color: selected ? TenaColors.orange : TenaColors.stone,
            ),
          ),
          child: Row(
            children: [
              Text(place.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TenaColors.ink,
                      ),
                    ),
                    Text(
                      '${place.category} · ${place.distanceLabel} km'
                      '${highlighted ? ' · For you' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TenaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
