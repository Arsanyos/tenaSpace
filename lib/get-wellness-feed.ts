import type {
  WellnessFeedData,
  WellnessFeedSection,
  WellnessPlaceCardData,
  WellnessSectionId,
  WellnessSuggestedAction,
} from "@/lib/mock-wellness-feed";
import type { WellnessProfile } from "@/lib/wellness";

const SECTION_TITLES: Record<WellnessSectionId, string> = {
  move: "🏃 Move Your Body",
  eat: "🥗 Eat Well",
  calm: "🧘 Calm Places",
  health: "🏥 Health Support",
};

const SECTION_ORDER: WellnessSectionId[] = ["move", "eat", "calm", "health"];

const GROQ_API_URL =
  process.env.GROQ_API_URL?.trim() || "https://api.groq.com/openai/v1/chat/completions";
// `llama-3.1-8b-instant` was retired by Groq; gpt-oss-20b is the current fast
// JSON-capable default. Override with GROQ_MODEL if your account differs.
const GROQ_MODEL = process.env.GROQ_MODEL?.trim() || "openai/gpt-oss-20b";

// The curated feed is ~1,500 output tokens. Groq's default cap (2,048) is
// shared with the model's hidden reasoning, which gpt-oss spends ~1,000
// tokens on by default — leaving the JSON truncated ("max completion tokens
// reached before generating a valid doc"). Keep reasoning minimal and give the
// document itself enough room.
const GROQ_MAX_COMPLETION_TOKENS = 4096;
const GROQ_REASONING_EFFORT = process.env.GROQ_REASONING_EFFORT?.trim() || "low";

export interface CuratedWellnessFeedResult {
  feed: WellnessFeedData | null;
  error: string | null;
}

function isWellnessSectionId(value: string): value is WellnessSectionId {
  return SECTION_ORDER.includes(value as WellnessSectionId);
}

function readString(source: object, key: string): string | null {
  const value = (source as Record<string, unknown>)[key];
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function readNumber(source: object, key: string): number | null {
  const value = (source as Record<string, unknown>)[key];
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function readTags(source: object): string[] {
  const tags = "tags" in source ? source.tags : null;
  if (!Array.isArray(tags)) return [];
  return tags
    .filter((tag): tag is string => typeof tag === "string" && tag.trim().length > 0)
    .slice(0, 5);
}

function readSuggestedActions(source: object): WellnessSuggestedAction[] {
  const actions = "suggestedActions" in source ? source.suggestedActions : null;
  if (!Array.isArray(actions)) return [];

  return actions
    .map((action): WellnessSuggestedAction | null => {
      if (!action || typeof action !== "object") return null;

      const type = readString(action, "type");
      const label = readString(action, "label");
      const description = readString(action, "description") ?? undefined;

      if (
        !type ||
        !label ||
        ![
          "breathing",
          "directions",
          "audio",
          "save",
          "timer",
          "checklist",
          "note",
          "call",
          "menu",
        ].includes(type)
      ) {
        return null;
      }

      return {
        type: type as WellnessSuggestedAction["type"],
        label,
        description,
      };
    })
    .filter((action): action is WellnessSuggestedAction => action !== null)
    .slice(0, 4);
}

function slugifyId(value: string): string {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 64);
}

function parsePlace(raw: unknown, requiredSection?: WellnessSectionId): WellnessPlaceCardData | null {
  if (!raw || typeof raw !== "object") return null;

  const id = readString(raw, "id");
  const name = readString(raw, "name");
  const category = readString(raw, "category");
  const emoji = readString(raw, "emoji");
  const recommendation = readString(raw, "recommendation");
  const sectionRaw = readString(raw, "section");
  const distanceKm = readNumber(raw, "distanceKm");

  const section = sectionRaw && isWellnessSectionId(sectionRaw) ? sectionRaw : requiredSection;
  if (!name || !category || !emoji || !recommendation || !section || distanceKm === null) {
    return null;
  }

  const lat = readNumber(raw, "lat");
  const lng = readNumber(raw, "lng");
  const durationMinutes = readNumber(raw, "durationMinutes");
  const bestTime = readString(raw, "bestTime") ?? undefined;
  const audioKindRaw = readString(raw, "audioKind");
  const audioKind =
    audioKindRaw === "walking-mix" ||
    audioKindRaw === "meditation" ||
    audioKindRaw === "ambient" ||
    audioKindRaw === "none"
      ? audioKindRaw
      : undefined;

  return {
    id: id ?? slugifyId(name),
    name,
    category,
    emoji,
    distanceKm,
    recommendation,
    section,
    tags: readTags(raw),
    lat: lat ?? undefined,
    lng: lng ?? undefined,
    durationMinutes: durationMinutes ?? undefined,
    bestTime,
    audioKind,
    suggestedActions: readSuggestedActions(raw),
  };
}

function dedupePlaces(places: WellnessPlaceCardData[]): WellnessPlaceCardData[] {
  const seen = new Set<string>();
  return places.map((place) => {
    if (!seen.has(place.id)) {
      seen.add(place.id);
      return place;
    }

    const uniqueId = `${place.id}-${seen.size + 1}`;
    seen.add(uniqueId);
    return { ...place, id: uniqueId };
  });
}

function parseCuratedFeed(raw: unknown): WellnessFeedData | null {
  if (!raw || typeof raw !== "object") return null;

  const featured = "featured" in raw ? parsePlace(raw.featured) : null;
  const sectionsRaw = "sections" in raw ? raw.sections : null;
  if (!featured || !Array.isArray(sectionsRaw)) return null;

  const sections: WellnessFeedSection[] = [];
  for (const sectionRaw of sectionsRaw) {
    if (!sectionRaw || typeof sectionRaw !== "object") continue;

    const sectionIdRaw = readString(sectionRaw, "id");
    if (!sectionIdRaw || !isWellnessSectionId(sectionIdRaw)) continue;

    const title = readString(sectionRaw, "title") ?? SECTION_TITLES[sectionIdRaw];
    const placesRaw = "places" in sectionRaw ? sectionRaw.places : null;
    if (!Array.isArray(placesRaw)) continue;

    const sectionPlaces = placesRaw
      .map((place) => parsePlace(place, sectionIdRaw))
      .filter((place): place is WellnessPlaceCardData => place !== null)
      .slice(0, 3);

    sections.push({
      id: sectionIdRaw,
      title,
      places: sectionPlaces,
    });
  }

  const orderedSections = SECTION_ORDER.map(
    (sectionId) =>
      sections.find((section) => section.id === sectionId) ?? {
        id: sectionId,
        title: SECTION_TITLES[sectionId],
        places: [],
      },
  );

  return {
    featured,
    sections: orderedSections.map((section) => ({
      ...section,
      places: dedupePlaces(section.places),
    })),
  };
}

function isValidFeed(feed: WellnessFeedData | null): feed is WellnessFeedData {
  if (!feed?.featured?.id) return false;
  return feed.sections.some((section) => section.places.length > 0);
}

async function requestGroqFeed(profile: WellnessProfile): Promise<WellnessFeedData | null> {
  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) throw new Error("GROQ_API_KEY is missing from the running Next.js server.");

  const systemPrompt = `You curate a personalized wellness feed for TenaSpace in Addis Ababa.
Return ONLY valid JSON (no markdown) matching this schema:
{
  "featured": {
    "id": string,
    "emoji": string,
    "name": string,
    "category": string,
    "section": "move" | "eat" | "calm" | "health",
    "distanceKm": number,
    "recommendation": string,
    "tags": string[],
    "lat": number,
    "lng": number,
    "durationMinutes": number,
    "bestTime": string,
    "audioKind": "walking-mix" | "meditation" | "ambient" | "none",
    "suggestedActions": [
      {
        "type": "breathing" | "directions" | "audio" | "save" | "timer" | "checklist" | "note" | "call" | "menu",
        "label": string,
        "description": string
      }
    ]
  },
  "sections": [
    {
      "id": "move" | "eat" | "calm" | "health",
      "title": string,
      "places": [same place object shape as featured]
    }
  ]
}
Rules:
- Generate actual, plausible Addis Ababa wellness places yourself. Do not rely on a provided catalog.
- Include all 4 sections in order: move, eat, calm, health.
- Return 2 places per section; places must belong to that section.
- Use stable kebab-case ids derived from each place name.
- Include realistic approximate lat/lng coordinates in Addis Ababa for every place.
- recommendation is one short personalized sentence per place (max 120 chars).
- Use "walking-mix" for walking/running routes, "meditation" for calm places, "ambient" for gentle non-calm audio, and "none" for food/medical places.
- suggestedActions must be specific to the place and section; do not repeat the same actions for every place.
- Include directions only when lat/lng are present. Include audio only when audioKind is not "none".
- Example actions: "Start a 12-minute walk", "Preview menu ideas", "Call before visiting", "Play calm background sound", "Save for sunset".
- Tone: warm, local, practical.`;

  const userPrompt = JSON.stringify({
    profile,
    city: "Addis Ababa, Ethiopia",
  });

  const response = await fetch(GROQ_API_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: GROQ_MODEL,
      temperature: 0.4,
      max_completion_tokens: GROQ_MAX_COMPLETION_TOKENS,
      reasoning_effort: GROQ_REASONING_EFFORT,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
    }),
    cache: "no-store",
  });

  if (!response.ok) {
    const details = await response.text().catch(() => "");
    throw new Error(details || `Groq returned HTTP ${response.status}.`);
  }

  const payload = (await response.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };

  const content = payload.choices?.[0]?.message?.content;
  if (!content) throw new Error("Groq response did not include message content.");

  try {
    return parseCuratedFeed(JSON.parse(content));
  } catch {
    throw new Error("Groq response was not valid JSON.");
  }
}

/**
 * Curates the wellness feed with Groq on the server only.
 * Returns null when the API key is missing, the request fails, or the response is invalid.
 */
export async function fetchCuratedWellnessFeed(
  profile: WellnessProfile,
): Promise<WellnessFeedData | null> {
  const result = await fetchCuratedWellnessFeedResult(profile);
  return result.feed;
}

export async function fetchCuratedWellnessFeedResult(
  profile: WellnessProfile,
): Promise<CuratedWellnessFeedResult> {
  try {
    const feed = await requestGroqFeed(profile);
    if (!isValidFeed(feed)) {
      return {
        feed: null,
        error:
          "Groq returned a feed, but it did not contain valid dynamic places.",
      };
    }

    return { feed, error: null };
  } catch (error) {
    return {
      feed: null,
      error: error instanceof Error ? error.message : "Unknown Groq curation error.",
    };
  }
}
