import { resolveAudioConfig, type ResolvedAudioConfig } from "@/lib/audio-config";
import type { MapPlace } from "@/lib/map-places";
import type {
  WellnessPlaceCardData,
  WellnessSectionId,
  WellnessSuggestedAction,
} from "@/lib/mock-wellness-feed";
import type { WellnessProfile } from "@/lib/wellness";

export interface WellnessPlaceDetailData {
  id: string;
  name: string;
  category: string;
  emoji: string;
  section: WellnessSectionId;
  distanceKm: number;
  tags: string[];
  whyRecommended: string;
  durationMinutes: number | null;
  bestTime: string | null;
  mapPlace: MapPlace | null;
  audioConfig: ResolvedAudioConfig | null;
  suggestedActions: WellnessSuggestedAction[];
}

function estimateWalkingDuration(place: WellnessPlaceCardData): number | null {
  if (place.durationMinutes) return place.durationMinutes;

  const isWalkingPlace =
    place.category.toLowerCase().includes("walk") ||
    (place.tags ?? []).some((tag) => tag.toLowerCase().includes("walk"));

  if (!isWalkingPlace) return null;

  // Use a friendly average pace of ~4.8 km/h for an easy wellness walk.
  return Math.max(8, Math.round((place.distanceKm / 4.8) * 60));
}

function toMapPlace(place: WellnessPlaceCardData): MapPlace | null {
  if (typeof place.lat !== "number" || typeof place.lng !== "number") return null;

  return {
    id: place.id,
    name: place.name,
    emoji: place.emoji,
    category: place.category,
    section: place.section,
    lat: place.lat,
    lng: place.lng,
    distanceKm: place.distanceKm,
  };
}

export function createPlaceDetailFromCuratedPlace(
  place: WellnessPlaceCardData,
  profile: WellnessProfile,
): WellnessPlaceDetailData {
  return {
    id: place.id,
    name: place.name,
    category: place.category,
    emoji: place.emoji,
    section: place.section,
    distanceKm: place.distanceKm,
    tags: place.tags ?? [],
    whyRecommended: place.recommendation,
    durationMinutes: estimateWalkingDuration(place),
    bestTime: place.bestTime ?? null,
    mapPlace: toMapPlace(place),
    audioConfig: resolveAudioConfig(place, profile),
    suggestedActions: place.suggestedActions ?? [],
  };
}
