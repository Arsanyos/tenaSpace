"use client";

import L from "leaflet";
import "leaflet/dist/leaflet.css";
import { useEffect, useRef } from "react";
import { ADDIS_MAP_CENTER, ADDIS_MAP_ZOOM } from "@/lib/map-places";
import type { MapPlace } from "@/lib/map-places";

interface WellnessMapClientProps {
  places: MapPlace[];
  highlightedIds: Set<string>;
  selectedId: string | null;
  onSelectPlace: (id: string) => void;
  interactive?: boolean;
  showZoomControls?: boolean;
}

function createEmojiIcon(emoji: string, highlighted: boolean) {
  return L.divIcon({
    className: "",
    html: `<div class="wellness-map-marker${highlighted ? " wellness-map-marker--highlighted" : ""}">${emoji}</div>`,
    iconSize: [44, 44],
    iconAnchor: [22, 44],
    popupAnchor: [0, -40],
  });
}

function syncMarkers(
  map: L.Map,
  places: MapPlace[],
  highlightedIds: Set<string>,
  onSelectPlace: (id: string) => void,
  markersRef: React.MutableRefObject<L.Marker[]>,
) {
  markersRef.current.forEach((marker) => marker.remove());
  markersRef.current = [];

  places.forEach((place) => {
    const highlighted = highlightedIds.has(place.id);
    const marker = L.marker([place.lat, place.lng], {
      icon: createEmojiIcon(place.emoji, highlighted),
    })
      .addTo(map)
      .bindPopup(
        `<strong>${place.name}</strong><br/><span style="color:#6b7280;font-size:13px">${place.category} · ${place.distanceKm} km</span>`,
      );

    marker.on("click", () => onSelectPlace(place.id));
    markersRef.current.push(marker);
  });

  if (places.length > 0) {
    const bounds = L.latLngBounds(places.map((p) => [p.lat, p.lng] as [number, number]));
    map.fitBounds(bounds, { padding: [48, 48], maxZoom: 14 });
  }
}

export function WellnessMapClient({
  places,
  highlightedIds,
  selectedId,
  onSelectPlace,
  interactive = true,
  showZoomControls = true,
}: WellnessMapClientProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<L.Map | null>(null);
  const markersRef = useRef<L.Marker[]>([]);
  const placesRef = useRef(places);
  const highlightedIdsRef = useRef(highlightedIds);
  const onSelectPlaceRef = useRef(onSelectPlace);

  useEffect(() => {
    placesRef.current = places;
    highlightedIdsRef.current = highlightedIds;
    onSelectPlaceRef.current = onSelectPlace;
  }, [places, highlightedIds, onSelectPlace]);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    let map: L.Map | null = null;
    let resizeObserver: ResizeObserver | null = null;

    const teardown = () => {
      resizeObserver?.disconnect();
      resizeObserver = null;
      if (map) {
        map.remove();
        map = null;
        mapRef.current = null;
        markersRef.current = [];
      }
    };

    const initMap = () => {
      if (map || !containerRef.current) return;
      const { clientWidth, clientHeight } = containerRef.current;
      if (clientWidth < 2 || clientHeight < 2) return;

      map = L.map(containerRef.current, {
        center: ADDIS_MAP_CENTER,
        zoom: ADDIS_MAP_ZOOM,
        zoomControl: false,
        dragging: interactive,
        touchZoom: interactive,
        doubleClickZoom: interactive,
        scrollWheelZoom: interactive,
        boxZoom: interactive,
        keyboard: interactive,
      });

      if (showZoomControls && interactive) {
        L.control.zoom({ position: "bottomright" }).addTo(map);
      }

      L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
        maxZoom: 19,
      }).addTo(map);

      mapRef.current = map;
      syncMarkers(
        map,
        placesRef.current,
        highlightedIdsRef.current,
        onSelectPlaceRef.current,
        markersRef,
      );

      requestAnimationFrame(() => map?.invalidateSize());
    };

    initMap();

    if (!map) {
      resizeObserver = new ResizeObserver(() => {
        initMap();
        if (map) resizeObserver?.disconnect();
      });
      resizeObserver.observe(container);
    }

    return teardown;
  }, [interactive, showZoomControls]);

  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    syncMarkers(map, places, highlightedIds, onSelectPlace, markersRef);
    requestAnimationFrame(() => map.invalidateSize());
  }, [places, highlightedIds, onSelectPlace]);

  useEffect(() => {
    const map = mapRef.current;
    if (!map || !selectedId) return;

    const place = places.find((p) => p.id === selectedId);
    if (!place) return;

    map.setView([place.lat, place.lng], Math.max(map.getZoom(), 14), { animate: true });
    const marker = markersRef.current.find((m) => {
      const latLng = m.getLatLng();
      return latLng.lat === place.lat && latLng.lng === place.lng;
    });
    marker?.openPopup();
  }, [selectedId, places]);

  return <div ref={containerRef} className="h-full min-h-[10rem] w-full" />;
}
