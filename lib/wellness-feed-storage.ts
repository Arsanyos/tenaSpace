import type { WellnessFeedData, WellnessPlaceCardData } from "@/lib/mock-wellness-feed";
import type { MapPlace } from "@/lib/map-places";

const CURATED_FEED_STORAGE_KEY = "tenaspace-latest-curated-feed";

export function saveCuratedWellnessFeed(feed: WellnessFeedData): void {
  if (typeof window === "undefined") return;
  sessionStorage.setItem(CURATED_FEED_STORAGE_KEY, JSON.stringify(feed));
}

export function loadCuratedWellnessFeed(): WellnessFeedData | null {
  if (typeof window === "undefined") return null;

  try {
    const raw = sessionStorage.getItem(CURATED_FEED_STORAGE_KEY);
    if (!raw) return null;

    const parsed = JSON.parse(raw) as WellnessFeedData;
    if (!parsed?.featured || !Array.isArray(parsed.sections)) return null;

    return parsed;
  } catch {
    return null;
  }
}

export function findCuratedFeedPlace(placeId: string): WellnessPlaceCardData | null {
  const feed = loadCuratedWellnessFeed();
  if (!feed) return null;

  if (feed.featured.id === placeId) return feed.featured;

  for (const section of feed.sections) {
    const place = section.places.find((entry) => entry.id === placeId);
    if (place) return place;
  }

  return null;
}

export function loadCuratedMapPlaces(): MapPlace[] {
  const feed = loadCuratedWellnessFeed();
  if (!feed) return [];

  const allPlaces = [feed.featured, ...feed.sections.flatMap((section) => section.places)];
  const seen = new Set<string>();

  return allPlaces
    .filter((place) => {
      if (seen.has(place.id)) return false;
      seen.add(place.id);
      return typeof place.lat === "number" && typeof place.lng === "number";
    })
    .map((place) => ({
      id: place.id,
      name: place.name,
      emoji: place.emoji,
      category: place.category,
      section: place.section,
      lat: place.lat as number,
      lng: place.lng as number,
      distanceKm: place.distanceKm,
    }));
}
