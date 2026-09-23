import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/tena_colors.dart';
import '../../../../core/theme/tena_decorations.dart';
import '../../domain/map_place.dart';

/// OpenStreetMap view with emoji markers — the Leaflet port.
///
/// [interactive] false renders a static preview (no gestures, no controls);
/// the parent decides what tapping the preview does.
class WellnessMap extends StatefulWidget {
  const WellnessMap({
    super.key,
    required this.places,
    this.highlightedIds = const {},
    this.selectedId,
    this.onSelectPlace,
    this.interactive = true,
    this.showZoomControls = true,
  });

  final List<MapPlace> places;
  final Set<String> highlightedIds;
  final String? selectedId;
  final ValueChanged<String>? onSelectPlace;
  final bool interactive;
  final bool showZoomControls;

  static const tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const focusZoom = 14.0;

  @override
  State<WellnessMap> createState() => _WellnessMapState();
}

class _WellnessMapState extends State<WellnessMap> {
  final _controller = MapController();

  @override
  void didUpdateWidget(covariant WellnessMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedId = widget.selectedId;
    if (selectedId != null && selectedId != oldWidget.selectedId) {
      _focusOn(selectedId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _focusOn(String placeId) {
    final place = _find(placeId);
    if (place == null) return;
    final zoom = math.max(_controller.camera.zoom, WellnessMap.focusZoom);
    _controller.move(place.point, zoom);
  }

  MapPlace? _find(String id) {
    for (final place in widget.places) {
      if (place.id == id) return place;
    }
    return null;
  }

  void _zoomBy(double delta) {
    final camera = _controller.camera;
    _controller.move(camera.center, camera.zoom + delta);
  }

  /// Bounds around every marker, a single-point focus, or Addis by default.
  MapOptions _buildOptions() {
    final points = widget.places.map((place) => place.point).toList();
    final selected = widget.selectedId == null
        ? null
        : _find(widget.selectedId!);

    final interaction = InteractionOptions(
      flags: widget.interactive
          ? InteractiveFlag.all & ~InteractiveFlag.rotate
          : InteractiveFlag.none,
    );

    if (selected != null) {
      return MapOptions(
        initialCenter: selected.point,
        initialZoom: WellnessMap.focusZoom,
        interactionOptions: interaction,
        backgroundColor: TenaColors.mapFrame,
      );
    }
    if (points.length == 1) {
      return MapOptions(
        initialCenter: points.single,
        initialZoom: WellnessMap.focusZoom,
        interactionOptions: interaction,
        backgroundColor: TenaColors.mapFrame,
      );
    }
    if (points.length > 1) {
      return MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(48),
          maxZoom: WellnessMap.focusZoom,
        ),
        interactionOptions: interaction,
        backgroundColor: TenaColors.mapFrame,
      );
    }
    return MapOptions(
      initialCenter: addisMapCenter,
      initialZoom: addisMapZoom,
      interactionOptions: interaction,
      backgroundColor: TenaColors.mapFrame,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: _buildOptions(),
          children: [
            TileLayer(
              urlTemplate: WellnessMap.tileUrl,
              userAgentPackageName: 'com.tenaspace.app',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                for (final place in widget.places)
                  if (place.id != widget.selectedId) _marker(place),
                // Painted last so its callout sits above neighbouring pins.
                for (final place in widget.places)
                  if (place.id == widget.selectedId) _marker(place),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
              backgroundColor: Color(0xCCFFFFFF),
              onTap: _openAttribution,
            ),
          ],
        ),
        if (widget.interactive && widget.showZoomControls)
          Positioned(
            right: 12,
            bottom: 28,
            child: _ZoomControls(
              onZoomIn: () => _zoomBy(1),
              onZoomOut: () => _zoomBy(-1),
            ),
          ),
      ],
    );
  }

  Marker _marker(MapPlace place) {
    final selected = place.id == widget.selectedId;
    final highlighted = widget.highlightedIds.contains(place.id);

    return Marker(
      key: ValueKey('marker-${place.id}'),
      point: place.point,
      width: selected ? 200 : 48,
      height: selected ? 116 : 48,
      // Bottom-centre of the marker widget sits on the coordinate.
      alignment: Alignment.topCenter,
      child: Semantics(
        button: widget.onSelectPlace != null,
        label: '${place.name}, ${place.category}, ${place.distanceLabel} km',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onSelectPlace == null
              ? null
              : () => widget.onSelectPlace!(place.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (selected) ...[
                _MarkerCallout(place: place),
                const SizedBox(height: 6),
              ],
              _MarkerBubble(emoji: place.emoji, highlighted: highlighted),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _openAttribution() => launchUrl(
    Uri.parse('https://www.openstreetmap.org/copyright'),
    mode: LaunchMode.externalApplication,
  );
}

/// `.wellness-map-marker`
class _MarkerBubble extends StatelessWidget {
  const _MarkerBubble({required this.emoji, required this.highlighted});

  final String emoji;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: TenaColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: highlighted ? TenaColors.orange : TenaColors.white,
          width: 2,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color(0x73502C19),
            offset: Offset(0, 10),
            blurRadius: 24,
            spreadRadius: -12,
          ),
          if (highlighted)
            BoxShadow(
              color: TenaColors.orange.withValues(alpha: 0.35),
              spreadRadius: 3,
            ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20, height: 1)),
    );
  }
}

/// Leaflet popup equivalent shown above the selected pin.
class _MarkerCallout extends StatelessWidget {
  const _MarkerCallout({required this.place});

  final MapPlace place;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TenaColors.white,
        borderRadius: BorderRadius.circular(TenaRadii.md),
        boxShadow: TenaShadows.lift,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            place.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: TenaColors.ink,
            ),
          ),
          Text(
            '${place.category} · ${place.distanceLabel} km',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TenaColors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(TenaRadii.md),
      elevation: 3,
      shadowColor: const Color(0x66172132),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom in',
            onPressed: onZoomIn,
            icon: const Icon(Icons.add_rounded, color: TenaColors.ink),
          ),
          const Divider(height: 1, color: TenaColors.stone),
          IconButton(
            tooltip: 'Zoom out',
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove_rounded, color: TenaColors.ink),
          ),
        ],
      ),
    );
  }
}
