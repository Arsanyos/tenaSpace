/** Shared wellness feed types (data comes from Groq curation only). */

export type WellnessSectionId = "move" | "eat" | "calm" | "health";
export type WellnessActionType =
  | "breathing"
  | "directions"
  | "audio"
  | "save"
  | "timer"
  | "checklist"
  | "note"
  | "call"
  | "menu";

export interface WellnessSuggestedAction {
  type: WellnessActionType;
  label: string;
  description?: string;
}

export interface WellnessPlaceCardData {
  id: string;
  emoji: string;
  name: string;
  category: string;
  distanceKm: number;
  recommendation: string;
  section: WellnessSectionId;
  tags?: string[];
  lat?: number;
  lng?: number;
  durationMinutes?: number;
  bestTime?: string;
  audioKind?: "walking-mix" | "meditation" | "ambient" | "none";
  suggestedActions?: WellnessSuggestedAction[];
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
