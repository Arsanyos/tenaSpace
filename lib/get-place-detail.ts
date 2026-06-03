import { resolveAudioConfig, type ResolvedAudioConfig } from "@/lib/audio-config";
import { MAP_PLACES, type MapPlace } from "@/lib/map-places";
import { places, type Place, type WellnessProfile } from "@/lib/wellness";

export interface WellnessPlaceDetailData {
  id: string;
  name: string;
  category: string;
  emoji: string;
  section: Place["section"];
  distanceKm: number;
  tags: string[];
  whyRecommended: string;
  durationMinutes: number | null;
  bestTime: string | null;
  mapPlace: MapPlace | null;
  audioConfig: ResolvedAudioConfig | null;
}

function estimateWalkingDuration(place: Place): number | null {
  if (place.durationMinutes) return place.durationMinutes;

  const isWalkingPlace =
    place.category.toLowerCase().includes("walk") ||
    place.tags.some((tag) => tag.toLowerCase().includes("walk"));

  if (!isWalkingPlace) return null;

  // Use a friendly average pace of ~4.8 km/h for an easy wellness walk.
  return Math.max(8, Math.round((place.distanceKm / 4.8) * 60));
}

export function getPlaceDetail(
  placeId: string,
  profile: WellnessProfile,
): WellnessPlaceDetailData | null {
  const place = places.find((entry) => entry.id === placeId);
  if (!place) return null;

  const mapPlace = MAP_PLACES.find((entry) => entry.id === place.id) ?? null;
  const whyRecommended = place.why(profile) ?? "Recommended for your wellness plan today";

  return {
    id: place.id,
    name: place.name,
    category: place.category,
    emoji: place.emoji,
    section: place.section,
    distanceKm: place.distanceKm,
    tags: place.tags,
    whyRecommended,
    durationMinutes: estimateWalkingDuration(place),
    bestTime: place.bestTime ?? null,
    mapPlace,
    audioConfig: resolveAudioConfig(place, profile),
  };
}
