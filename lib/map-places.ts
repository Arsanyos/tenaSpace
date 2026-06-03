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
  {
    id: "meskel-walk",
    name: "Meskel Square Walking Route",
    emoji: "🚶",
    category: "Walking route",
    section: "move",
    lat: 9.0105,
    lng: 38.761,
    distanceKm: 0.9,
  },
  {
    id: "bole-court",
    name: "Bole Community Basketball Court",
    emoji: "🏀",
    category: "Basketball court",
    section: "move",
    lat: 8.987,
    lng: 38.789,
    distanceKm: 1.8,
  },
  {
    id: "kazanchis-bowl",
    name: "Kazanchis Healthy Bowl Cafe",
    emoji: "🥗",
    category: "Healthy cafe",
    section: "eat",
    lat: 9.0167,
    lng: 38.752,
    distanceKm: 1.2,
  },
  {
    id: "sunrise-juice",
    name: "Sunrise Fresh Juice Bar",
    emoji: "🥤",
    category: "Cafe",
    section: "eat",
    lat: 8.993,
    lng: 38.781,
    distanceKm: 1.6,
  },
  {
    id: "entoto-view",
    name: "Entoto Quiet Viewpoint",
    emoji: "🌄",
    category: "Calm space",
    section: "calm",
    lat: 9.092,
    lng: 38.764,
    distanceKm: 4.2,
  },
  {
    id: "ghion-garden",
    name: "Ghion Garden Meditation Lawn",
    emoji: "🌿",
    category: "Quiet park",
    section: "calm",
    lat: 9.018,
    lng: 38.755,
    distanceKm: 2.0,
  },
  {
    id: "megenagna-clinic",
    name: "Megenagna Family Clinic",
    emoji: "🏥",
    category: "Clinic",
    section: "health",
    lat: 9.012,
    lng: 38.79,
    distanceKm: 1.5,
  },
  {
    id: "bole-hospital",
    name: "Bole Wellness Hospital",
    emoji: "➕",
    category: "Hospital",
    section: "health",
    lat: 8.98,
    lng: 38.795,
    distanceKm: 3.8,
  },
];

export const ADDIS_MAP_CENTER: [number, number] = [9.032, 38.747];
export const ADDIS_MAP_ZOOM = 13;
