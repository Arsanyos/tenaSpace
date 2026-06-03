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

export const emptyProfile: WellnessProfile = {
  goals: [],
  interests: [],
  diets: [],
  mood: null,
};
