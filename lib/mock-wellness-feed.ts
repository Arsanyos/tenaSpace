/**
 * Mock wellness feed for the home screen prototype.
 * Review and adjust copy, tags, or sections here before wiring real APIs.
 */

export type WellnessSectionId = "move" | "eat" | "calm" | "health";

export interface WellnessPlaceCardData {
  id: string;
  emoji: string;
  name: string;
  category: string;
  distanceKm: number;
  recommendation: string;
  tags?: string[];
}

export interface WellnessFeedSection {
  id: WellnessSectionId;
  title: string;
  places: WellnessPlaceCardData[];
}

export interface WellnessFeedData {
  featured: WellnessPlaceCardData;
  sections: WellnessFeedSection[];
}

export const MOCK_WELLNESS_FEED: WellnessFeedData = {
  featured: {
    id: "meskel-walk-featured",
    emoji: "🚶",
    name: "Meskel Square Walking Route",
    category: "Walking route",
    distanceKm: 0.9,
    recommendation: "Picked just for you",
  },
  sections: [
    {
      id: "move",
      title: "🏃 Move Your Body",
      places: [
        {
          id: "meskel-walk",
          emoji: "🚶",
          name: "Meskel Square Walking Route",
          category: "Walking route",
          distanceKm: 0.9,
          recommendation: "Recommended walking route near you",
          tags: ["Walking", "Fresh Air"],
        },
        {
          id: "bole-court",
          emoji: "🏀",
          name: "Bole Community Basketball Court",
          category: "Basketball court",
          distanceKm: 1.8,
          recommendation: "Recommended basketball court near you",
          tags: ["Basketball", "Open Now", "Outdoor"],
        },
      ],
    },
    {
      id: "eat",
      title: "🥗 Eat Well",
      places: [
        {
          id: "kazanchis-bowl",
          emoji: "🥗",
          name: "Kazanchis Healthy Bowl Cafe",
          category: "Healthy cafe",
          distanceKm: 1.2,
          recommendation: "Diabetic-friendly meal options",
          tags: ["Low Sugar", "High Protein", "Vegetarian"],
        },
        {
          id: "sunrise-juice",
          emoji: "🥤",
          name: "Sunrise Fresh Juice Bar",
          category: "Cafe",
          distanceKm: 1.6,
          recommendation: "You like healthy cafes",
          tags: ["Low Sugar", "Vegetarian"],
        },
      ],
    },
    {
      id: "calm",
      title: "🧘 Calm Places",
      places: [
        {
          id: "entoto-view",
          emoji: "🌄",
          name: "Entoto Quiet Viewpoint",
          category: "Meditation / Fresh Air",
          distanceKm: 4.2,
          recommendation: "A calm place for your mood today",
          tags: ["Quiet", "Fresh Air", "Free"],
        },
        {
          id: "ghion-garden",
          emoji: "🌿",
          name: "Ghion Garden Meditation Lawn",
          category: "Quiet park",
          distanceKm: 2.0,
          recommendation: "Great for yoga and meditation",
          tags: ["Quiet", "Meditation"],
        },
      ],
    },
    {
      id: "health",
      title: "🏥 Health Support",
      places: [
        {
          id: "megenagna-clinic",
          emoji: "🏥",
          name: "Megenagna Family Clinic",
          category: "Clinic",
          distanceKm: 1.5,
          recommendation: "Recommended clinic near you",
          tags: ["Clinic", "Open Now"],
        },
        {
          id: "bole-hospital",
          emoji: "➕",
          name: "Bole Wellness Hospital",
          category: "Hospital",
          distanceKm: 3.8,
          recommendation: "Recommended hospital near you",
          tags: ["Hospital", "Diabetes Care"],
        },
      ],
    },
  ],
};
