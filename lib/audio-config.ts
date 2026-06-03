import type { WellnessSectionId } from "@/lib/mock-wellness-feed";
import type { WellnessProfile } from "@/lib/wellness";

export type AudioKind = "walking-mix" | "meditation" | "ambient";

export interface AudioConfig {
  kind: AudioKind;
  label: string;
  basePrompt: string;
  durationSeconds: number;
  loop: boolean;
  /** When set, the player uses this file from /public instead of calling the AI API. */
  staticSrc?: string;
}

export interface ResolvedAudioConfig extends AudioConfig {
  prompt: string;
}

interface AudioPlaceInput {
  id: string;
  section: WellnessSectionId;
  audioKind?: AudioKind | "none";
}

const DEFAULT_AUDIO_BY_SECTION: Record<WellnessSectionId, AudioConfig | null> = {
  move: {
    kind: "walking-mix",
    label: "Play AI walking soundscape",
    basePrompt:
      "Instrumental walking ambience with gentle rhythm, warm Ethiopian-inspired textures, soft percussion, and a positive steady pace.",
    durationSeconds: 35,
    loop: true,
  },
  eat: null,
  calm: {
    kind: "meditation",
    label: "Play calm background sound",
    basePrompt:
      "Slow meditative ambient soundscape with soft sustained pads, light wind, and very gentle Ethiopian-inspired acoustic textures.",
    durationSeconds: 45,
    loop: true,
    staticSrc: "/audio/calm-meditation.mp3",
  },
  health: null,
};

const AUDIO_BY_PLACE: Record<string, AudioConfig> = {
  "meskel-walk": {
    kind: "walking-mix",
    label: "Play AI walking soundscape",
    basePrompt:
      "Uplifting morning walking ambience with gentle motion, soft city air, subtle Ethiopian krar plucks, and calm focus energy.",
    durationSeconds: 40,
    loop: true,
  },
  "entoto-view": {
    kind: "meditation",
    label: "Play calm background sound",
    basePrompt:
      "Peaceful mountain-top meditation ambience with spacious wind, distant birds, and slow grounding ambient pads.",
    durationSeconds: 50,
    loop: true,
    staticSrc: "/audio/entoto-meditation.mp3",
  },
  "ghion-garden": {
    kind: "meditation",
    label: "Play calm background sound",
    basePrompt:
      "Quiet garden meditation ambience with warm pads, soft natural textures, and a deeply relaxing low-energy pace.",
    durationSeconds: 45,
    loop: true,
    staticSrc: "/audio/ghion-meditation.mp3",
  },
};

const MOOD_HINTS: Record<NonNullable<WellnessProfile["mood"]>, string> = {
  calm: "Keep the sound soft and steady.",
  stressed: "Use very gentle pacing that encourages slow breathing.",
  tired: "Use warm low-energy tones for recovery.",
  anxious: "Use grounding low textures with minimal sudden changes.",
  motivated: "Add subtle uplifting motion while staying calm.",
  "fresh-air": "Blend airy outdoor textures and light breeze.",
};

function getBaseAudioConfig(place: AudioPlaceInput): AudioConfig | null {
  if (place.audioKind === "none") return null;
  if (place.audioKind) {
    return DEFAULT_AUDIO_BY_SECTION[place.section];
  }

  return AUDIO_BY_PLACE[place.id] ?? DEFAULT_AUDIO_BY_SECTION[place.section];
}

export function buildPrompt(basePrompt: string, profile: WellnessProfile): string {
  const moodHint = profile.mood ? ` Mood adaptation: ${MOOD_HINTS[profile.mood]}` : "";
  return `${basePrompt}${moodHint} Instrumental only, no vocals.`;
}

export function resolveAudioConfig(
  place: AudioPlaceInput,
  profile: WellnessProfile,
): ResolvedAudioConfig | null {
  const baseConfig = getBaseAudioConfig(place);
  if (!baseConfig) return null;

  return {
    ...baseConfig,
    prompt: buildPrompt(baseConfig.basePrompt, profile),
  };
}
