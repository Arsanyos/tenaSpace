import type { WellnessSectionId } from "@/lib/mock-wellness-feed";

export interface MapPlace {
  id: string;
  name: string;
  emoji: string;
  category: string;
  section: WellnessSectionId;
  lat: number;
  lng: number;
  distanceKm: number;
}

/** Addis Ababa wellness locations for the map prototype. */
export const MAP_PLACES: MapPlace[] = [
];

export const ADDIS_MAP_CENTER: [number, number] = [9.032, 38.747];
export const ADDIS_MAP_ZOOM = 13;
