export type Goal = "active" | "eat" | "stress" | "medical" | "discover";
export type Interest =
  | "basketball"
  | "football"
  | "tennis"
  | "running"
  | "gym"
  | "yoga"
  | "walking"
  | "cafes";
export type Diet =
  | "diabetic"
  | "low-sugar"
  | "high-protein"
  | "vegetarian"
  | "weight"
  | "heart"
  | "none";
export type Mood = "calm" | "stressed" | "tired" | "anxious" | "motivated" | "fresh-air";

export interface WellnessProfile {
  goals: Goal[];
  interests: Interest[];
  diets: Diet[];
  mood: Mood | null;
}

export interface Place {
  id: string;
  name: string;
  category: string;
  distanceKm: number;
  tags: string[];
  section: "move" | "eat" | "calm" | "health";
  emoji: string;
  highlight?: string;
  durationMinutes?: number;
  bestTime?: string;
  why: (profile: WellnessProfile) => string | null;
}

export const emptyProfile: WellnessProfile = {
  goals: [],
  interests: [],
  diets: [],
  mood: null,
};

export const places: Place[] = [
  {
    id: "meskel-walk",
    name: "Meskel Square Walking Route",
    category: "Walking route",
    distanceKm: 0.9,
    durationMinutes: 12,
    bestTime: "Morning or sunset",
    section: "move",
    emoji: "🚶",
    tags: ["Walking", "Fresh Air"],
    highlight: "Picked just for you",
    why: (profile) =>
      profile.interests.includes("walking")
        ? "Recommended walking route near you"
        : profile.mood === "fresh-air"
          ? "Fresh air close to your area"
          : "Easy movement to start your day",
  },
  {
    id: "bole-court",
    name: "Bole Community Basketball Court",
    category: "Basketball court",
    distanceKm: 1.8,
    section: "move",
    emoji: "🏀",
    tags: ["Basketball", "Open Now", "Outdoor"],
    why: (profile) =>
      profile.interests.includes("basketball")
        ? "Recommended basketball court near you"
        : "A nearby outdoor option to stay active",
  },
  {
    id: "kazanchis-bowl",
    name: "Kazanchis Healthy Bowl Cafe",
    category: "Healthy cafe",
    distanceKm: 1.2,
    section: "eat",
    emoji: "🥗",
    tags: ["Low Sugar", "High Protein", "Vegetarian"],
    why: (profile) =>
      profile.diets.includes("diabetic")
        ? "Diabetic-friendly meal options"
        : profile.goals.includes("eat")
          ? "Recommended healthy cafe near you"
          : "Balanced meals around Kazanchis",
  },
  {
    id: "sunrise-juice",
    name: "Sunrise Fresh Juice Bar",
    category: "Cafe",
    distanceKm: 1.6,
    section: "eat",
    emoji: "🥤",
    tags: ["Low Sugar", "Vegetarian"],
    why: (profile) =>
      profile.interests.includes("cafes")
        ? "You like healthy cafes"
        : profile.goals.includes("eat")
          ? "Healthy hydration stop near your route"
          : "Fresh options around your area",
  },
  {
    id: "entoto-view",
    name: "Entoto Quiet Viewpoint",
    category: "Meditation / Fresh Air",
    distanceKm: 4.2,
    bestTime: "Morning or sunset",
    section: "calm",
    emoji: "🌄",
    tags: ["Quiet", "Fresh Air", "Free"],
    why: (profile) =>
      profile.mood === "stressed" || profile.mood === "anxious"
        ? "A calm place for your mood today"
        : "Quiet air above the city",
  },
  {
    id: "ghion-garden",
    name: "Ghion Garden Meditation Lawn",
    category: "Quiet park",
    distanceKm: 2,
    bestTime: "Late afternoon",
    section: "calm",
    emoji: "🌿",
    tags: ["Quiet", "Meditation"],
    why: (profile) =>
      profile.interests.includes("yoga")
        ? "Great for yoga and meditation"
        : profile.mood === "tired"
          ? "A restful calm space nearby"
          : "Quiet garden spot to reset",
  },
  {
    id: "megenagna-clinic",
    name: "Megenagna Family Clinic",
    category: "Clinic",
    distanceKm: 1.5,
    section: "health",
    emoji: "🏥",
    tags: ["Clinic", "Open Now"],
    why: (profile) =>
      profile.goals.includes("medical")
        ? "Recommended clinic near you"
        : "Nearby care if you need support",
  },
  {
    id: "bole-hospital",
    name: "Bole Wellness Hospital",
    category: "Hospital",
    distanceKm: 3.8,
    section: "health",
    emoji: "➕",
    tags: ["Hospital", "Diabetes Care"],
    why: (profile) =>
      profile.diets.includes("diabetic")
        ? "Recommended hospital near you"
        : "Full-service medical support nearby",
  },
];

export function scorePlace(place: Place, profile: WellnessProfile) {
  let score = 0;

  if (place.section === "move" && profile.goals.includes("active")) score += 2;
  if (place.section === "eat" && profile.goals.includes("eat")) score += 2;
  if (place.section === "calm" && profile.goals.includes("stress")) score += 2;
  if (place.section === "health" && profile.goals.includes("medical")) score += 2;
  if (place.why(profile)) score += 4;

  return score - place.distanceKm * 0.1;
}

export function recommendedPlaces(profile: WellnessProfile, section?: Place["section"]) {
  return [...places]
    .filter((place) => (section ? place.section === section : true))
    .sort((a, b) => scorePlace(b, profile) - scorePlace(a, profile));
}
