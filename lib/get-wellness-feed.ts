import type {
  WellnessFeedData,
  WellnessFeedSection,
  WellnessPlaceCardData,
  WellnessSectionId,
} from "@/lib/mock-wellness-feed";
import { places, recommendedPlaces, type Place, type WellnessProfile } from "@/lib/wellness";

const SECTION_TITLES: Record<WellnessSectionId, string> = {
  move: "🏃 Move Your Body",
  eat: "🥗 Eat Well",
  calm: "🧘 Calm Places",
  health: "🏥 Health Support",
};

const SECTION_ORDER: WellnessSectionId[] = ["move", "eat", "calm", "health"];

function toCardData(place: Place, profile: WellnessProfile, featured = false): WellnessPlaceCardData {
  const fallback = featured ? "Picked for your wellness plan" : "Recommended near your area";
  return {
    id: place.id,
    emoji: place.emoji,
    name: place.name,
    category: place.category,
    distanceKm: place.distanceKm,
    recommendation: place.highlight ?? place.why(profile) ?? fallback,
    tags: place.tags,
  };
}

function buildSections(profile: WellnessProfile): WellnessFeedSection[] {
  return SECTION_ORDER.map((sectionId) => ({
    id: sectionId,
    title: SECTION_TITLES[sectionId],
    places: recommendedPlaces(profile, sectionId)
      .slice(0, 2)
      .map((place) => toCardData(place, profile)),
  }));
}

/**
 * Builds the home wellness feed from the user's profile preferences.
 *
 * TODO: Rank and filter places with `recommendedPlaces`, map `Place` → card data,
 * and replace mock sections with API responses.
 */
export function getPersonalizedWellnessFeed(profile: WellnessProfile): WellnessFeedData {
  const ranked = recommendedPlaces(profile);
  const featuredPlace = ranked[0] ?? places[0];
  const sections = buildSections(profile);

  if (!featuredPlace) {
    return {
      featured: {
        id: "no-places",
        emoji: "🌅",
        name: "No places available",
        category: "Wellness",
        distanceKm: 0,
        recommendation: "Please try again later",
      },
      sections,
    };
  }

  return {
    featured: toCardData(featuredPlace, profile, true),
    sections,
  };
}
