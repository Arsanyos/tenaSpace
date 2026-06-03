TenaSpace — Personalized Wellness App for Addis Ababa
A complete build specification for Cursor (or any AI coding assistant) to recreate the TenaSpace prototype on a local dev server, with an added feature: AI-generated background music when a user taps "Play calm background sound" on a place detail.

1. Product Concept (read this first)
TenaSpace is a mobile-first, frontend-only clickable prototype for a wellness hackathon. The pitch line, used on the home screen:

TenaSpace turns your city into a personalized wellness map.

The product:

Learns who the user is through a 4-step onboarding (goals, interests, diet/health, mood).
Recommends real Addis Ababa wellness places scored against that profile (Bole, Lideta, Meskel Square, Entoto, Ghion, Kazanchis, Megenagna).
Surfaces suggested wellness actions per place: breathing, directions, save, and — for "calm" places — AI-generated calming background music that streams while the user reads.
Includes mocked side features: map view, "Heartbeat" BPM simulator, saved places, profile.
Tone: warm, modern, locally-Ethiopian (sunrise palette, dotted/cross-hatch "tena-pattern" overlay, "Selam 👋" greeting).

Judges should understand within 30 seconds: the app learns the user → recommends places → is local → can grow into a wellness ecosystem.

2. Tech Stack
Layer	Choice
Framework	TanStack Start v1 (React 19 + Vite 7, SSR + server functions)
Routing	File-based, in src/routes/ (TanStack Router)
Styling	Tailwind CSS v4 via @import "tailwindcss" in src/styles.css — no tailwind.config.js
Components	shadcn/ui (Radix) under src/components/ui/
State	React Context (WellnessProvider) — no DB, no auth
Icons	lucide-react
Server (for music)	TanStack Start server route under src/routes/api/
AI Music	ElevenLabs Music API (requires ELEVENLABS_API_KEY env var)
If you scaffold from scratch in Cursor, you can also use a plain Vite + React + React Router setup — adapt the routing section below. The rest of the spec (components, state, styling, music feature) is portable.

3. Project Structure
src/
├── routes/
│   ├── __root.tsx              # html shell + WellnessProvider + QueryClient
│   ├── index.tsx               # splash → onboarding
│   ├── onboarding.tsx          # 4-step profile builder
│   ├── app.tsx                 # layout: PhoneShell + BottomNav + <Outlet />
│   ├── app.index.tsx           # redirect to /app/home
│   ├── app.home.tsx            # personalized home
│   ├── app.place.$id.tsx       # place detail + AI music player
│   ├── app.map.tsx             # map mockup
│   ├── app.heartbeat.tsx       # BPM simulator
│   ├── app.saved.tsx           # saved places
│   ├── app.profile.tsx         # profile + reset
│   └── api/
│       └── generate-music.ts   # server route → ElevenLabs Music
├── components/
│   ├── PhoneShell.tsx          # centered phone frame on desktop
│   ├── BottomNav.tsx           # 5 tabs: Home, Map, Heartbeat, Saved, Profile
│   ├── PlaceCard.tsx           # list card with "why recommended"
│   ├── SelectableCard.tsx      # onboarding toggle card
│   └── ui/                     # shadcn/ui primitives
├── lib/
│   └── wellness-store.tsx      # Context + types + scoring + mock PLACES
└── styles.css                  # Tailwind v4 + design tokens
4. Design System (src/styles.css)
Use CSS-first Tailwind v4 with oklch() tokens. Never hard-code colors in components — always use semantic tokens (bg-primary, text-foreground, etc.) or the custom utilities below.

@import "tailwindcss" source(none);
@source "../src";
@import "tw-animate-css";

@custom-variant dark (&:is(.dark *));

@theme inline {
  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
  --radius-2xl: calc(var(--radius) + 8px);
  --radius-3xl: calc(var(--radius) + 12px);
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);
  --color-popover: var(--popover);
  --color-popover-foreground: var(--popover-foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-destructive: var(--destructive);
  --color-destructive-foreground: var(--destructive-foreground);
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);
  --color-clay: var(--clay);
  --color-cream: var(--cream);
  --color-sage: var(--sage);
  --color-deep: var(--deep);
  --color-sun: var(--sun);
  --background-image-sunrise: var(--gradient-sunrise);
  --background-image-warm: var(--gradient-warm);
  --background-image-calm: var(--gradient-calm);
  --shadow-soft: var(--shadow-soft);
  --shadow-lift: var(--shadow-lift);
}

:root {
  --radius: 1.1rem;

  /* Ethiopian sunrise palette */
  --background: oklch(0.985 0.012 80);          /* cream */
  --foreground: oklch(0.24 0.04 250);           /* deep blue ink */

  --card: oklch(1 0 0);
  --card-foreground: oklch(0.24 0.04 250);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.24 0.04 250);

  --primary: oklch(0.7 0.17 45);                /* warm orange */
  --primary-foreground: oklch(0.99 0.01 80);

  --secondary: oklch(0.94 0.04 70);             /* soft clay tint */
  --secondary-foreground: oklch(0.32 0.06 40);

  --muted: oklch(0.95 0.02 80);
  --muted-foreground: oklch(0.5 0.03 60);

  --accent: oklch(0.62 0.13 155);               /* sage green */
  --accent-foreground: oklch(0.99 0.01 80);

  --destructive: oklch(0.6 0.22 25);
  --destructive-foreground: oklch(0.99 0.01 80);

  --border: oklch(0.9 0.02 70);
  --input: oklch(0.9 0.02 70);
  --ring: oklch(0.7 0.17 45);

  --clay: oklch(0.62 0.12 40);
  --cream: oklch(0.97 0.025 80);
  --sage: oklch(0.62 0.13 155);
  --deep: oklch(0.32 0.08 255);
  --sun: oklch(0.82 0.16 75);

  --gradient-sunrise: linear-gradient(160deg, oklch(0.92 0.07 80) 0%, oklch(0.82 0.13 55) 45%, oklch(0.68 0.16 35) 100%);
  --gradient-warm: linear-gradient(135deg, oklch(0.97 0.03 80), oklch(0.92 0.06 65));
  --gradient-calm: linear-gradient(160deg, oklch(0.94 0.04 200) 0%, oklch(0.85 0.06 170) 100%);

  --shadow-soft: 0 6px 20px -10px oklch(0.4 0.1 40 / 0.25);
  --shadow-lift: 0 18px 40px -20px oklch(0.3 0.12 40 / 0.35);
}

@layer base {
  * { border-color: var(--color-border); }
  html, body, #root { height: 100%; }
  body {
    background-color: var(--color-background);
    color: var(--color-foreground);
    font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
    -webkit-font-smoothing: antialiased;
  }
  h1, h2, h3 { letter-spacing: -0.02em; }
}

/* Subtle Ethiopian-inspired pattern */
.tena-pattern {
  background-image:
    radial-gradient(circle at 20% 20%, oklch(1 0 0 / 0.18) 0 2px, transparent 3px),
    radial-gradient(circle at 80% 60%, oklch(1 0 0 / 0.12) 0 2px, transparent 3px),
    repeating-linear-gradient(45deg, oklch(1 0 0 / 0.06) 0 2px, transparent 2px 14px);
}

.fade-in { animation: fadeIn 0.4s ease-out both; }
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
Utility classes that come from this:

bg-sunrise, bg-warm, bg-calm (gradient backgrounds)
tena-pattern (decorative overlay)
shadow-[var(--shadow-soft)], shadow-[var(--shadow-lift)]
fade-in animation
5. Wellness Store (src/lib/wellness-store.tsx)
The single source of truth. Holds the user profile, the mock places, the scoring function, and saved IDs.

import { createContext, useContext, useMemo, useState, type ReactNode } from "react";

export type Goal = "active" | "eat" | "stress" | "medical" | "discover";
export type Interest =
  | "basketball" | "football" | "tennis" | "running"
  | "gym" | "yoga" | "walking" | "cafes";
export type Diet =
  | "diabetic" | "low-sugar" | "high-protein" | "vegetarian"
  | "weight" | "heart" | "none";
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
  why: (p: WellnessProfile) => string | null;
  section: "move" | "eat" | "calm" | "health";
  emoji: string;
  bestTime?: string;
  /** Prompt for ElevenLabs Music when user taps "Play calm background sound". */
  musicPrompt?: string;
}

const PLACES: Place[] = [
  {
    id: "bole-court", name: "Bole Community Basketball Court",
    category: "Basketball court", distanceKm: 1.8, section: "move", emoji: "🏀",
    tags: ["Basketball", "Open Now", "Outdoor"],
    why: (p) => p.interests.includes("basketball") ? "Recommended because you selected basketball" : null,
  },
  {
    id: "lideta-sports", name: "Lideta Sports Ground",
    category: "Football pitch", distanceKm: 3.1, section: "move", emoji: "⚽",
    tags: ["Football", "Open Now"],
    why: (p) => p.interests.includes("football") ? "Recommended because you selected football" : null,
  },
  {
    id: "atlas-gym", name: "Atlas Gym & Wellness",
    category: "Gym", distanceKm: 2.4, section: "move", emoji: "🏋️",
    tags: ["Gym", "Strength", "Open Now"],
    why: (p) =>
      p.interests.includes("gym") ? "Recommended because you selected gym" :
      p.goals.includes("active") ? "Matches your goal to stay active" : null,
  },
  {
    id: "meskel-walk", name: "Meskel Square Walking Route",
    category: "Walking route", distanceKm: 0.9, section: "move", emoji: "🚶",
    tags: ["Walking", "Fresh Air"],
    musicPrompt: "Soft uplifting morning ambience with gentle Ethiopian krar strings, light wind, and a slow walking rhythm — calm, motivating, instrumental.",
    why: (p) =>
      p.interests.includes("walking") ? "Recommended because you enjoy walking" :
      p.mood === "fresh-air" ? "You said you need fresh air today" : null,
  },
  {
    id: "kazanchis-bowl", name: "Kazanchis Healthy Bowl Cafe",
    category: "Healthy cafe", distanceKm: 1.2, section: "eat", emoji: "🥗",
    tags: ["Low Sugar", "High Protein", "Vegetarian"],
    why: (p) =>
      p.diets.includes("diabetic") ? "Diabetic-friendly menu options" :
      p.diets.includes("low-sugar") ? "Low-sugar bowls on the menu" :
      p.goals.includes("eat") ? "Matches your goal to eat healthier" : null,
  },
  {
    id: "sunrise-juice", name: "Sunrise Fresh Juice Bar",
    category: "Cafe", distanceKm: 1.6, section: "eat", emoji: "🥤",
    tags: ["Low Sugar", "Vegetarian"],
    why: (p) => p.interests.includes("cafes") ? "You like healthy cafes" : null,
  },
  {
    id: "heart-kitchen", name: "Heart-Friendly Kitchen",
    category: "Restaurant", distanceKm: 2.7, section: "eat", emoji: "🍲",
    tags: ["Heart-friendly", "Low Sugar"],
    why: (p) => p.diets.includes("heart") ? "Heart-friendly meals fit your preference" : null,
  },
  {
    id: "entoto-view", name: "Entoto Quiet Viewpoint",
    category: "Meditation / Fresh Air", distanceKm: 4.2, section: "calm", emoji: "🌄",
    tags: ["Quiet", "Fresh Air", "Free"],
    bestTime: "Morning or sunset",
    musicPrompt: "Serene mountaintop ambience: distant wind, faint bird calls, and a slow ambient pad with Ethiopian washint flute — meditative, vast, peaceful.",
    why: (p) =>
      p.mood === "stressed" || p.mood === "anxious"
        ? "You said you feel stressed and need fresh air"
        : p.mood === "fresh-air" ? "Perfect for the fresh air you need today" :
        p.goals.includes("stress") ? "A calm space to reduce stress" : null,
  },
  {
    id: "ghion-garden", name: "Ghion Garden Meditation Lawn",
    category: "Quiet park", distanceKm: 2.0, section: "calm", emoji: "🌿",
    tags: ["Quiet", "Meditation"],
    musicPrompt: "Soft meditation music with warm pads, gentle krar plucks, and faint garden birds — slow tempo, deeply relaxing, instrumental.",
    why: (p) => p.interests.includes("yoga") ? "Great for yoga and meditation" :
      p.mood === "tired" ? "A restful space when you're tired" : null,
  },
  {
    id: "megenagna-clinic", name: "Megenagna Family Clinic",
    category: "Clinic", distanceKm: 1.5, section: "health", emoji: "🏥",
    tags: ["Clinic", "Open Now"],
    why: (p) => p.goals.includes("medical") ? "Recommended because this clinic is near your area" : null,
  },
  {
    id: "bole-hospital", name: "Bole Wellness Hospital",
    category: "Hospital", distanceKm: 3.8, section: "health", emoji: "➕",
    tags: ["Hospital", "Diabetes Care"],
    why: (p) =>
      p.diets.includes("diabetic") ? "Has a diabetes care unit" :
      p.goals.includes("medical") ? "Full-service hospital nearby" : null,
  },
];

function score(place: Place, p: WellnessProfile): number {
  let s = 0;
  if (place.why(p)) s += 5;
  if (place.section === "move" && p.goals.includes("active")) s += 2;
  if (place.section === "eat" && p.goals.includes("eat")) s += 2;
  if (place.section === "calm" && p.goals.includes("stress")) s += 2;
  if (place.section === "health" && p.goals.includes("medical")) s += 2;
  s -= place.distanceKm * 0.1;
  return s;
}

interface Ctx {
  profile: WellnessProfile;
  setGoals: (g: Goal[]) => void;
  setInterests: (i: Interest[]) => void;
  setDiets: (d: Diet[]) => void;
  setMood: (m: Mood) => void;
  reset: () => void;
  places: Place[];
  getPlace: (id: string) => Place | undefined;
  recommendedFor: (section?: Place["section"]) => Place[];
  topMatch: () => Place | undefined;
  savedIds: string[];
  toggleSaved: (id: string) => void;
}

const C = createContext<Ctx | null>(null);
const EMPTY: WellnessProfile = { goals: [], interests: [], diets: [], mood: null };

export function WellnessProvider({ children }: { children: ReactNode }) {
  const [profile, setProfile] = useState<WellnessProfile>(EMPTY);
  const [savedIds, setSaved] = useState<string[]>([]);

  const value = useMemo<Ctx>(() => {
    const ranked = [...PLACES].sort((a, b) => score(b, profile) - score(a, profile));
    return {
      profile,
      setGoals: (goals) => setProfile((p) => ({ ...p, goals })),
      setInterests: (interests) => setProfile((p) => ({ ...p, interests })),
      setDiets: (diets) => setProfile((p) => ({ ...p, diets })),
      setMood: (mood) => setProfile((p) => ({ ...p, mood })),
      reset: () => setProfile(EMPTY),
      places: PLACES,
      getPlace: (id) => PLACES.find((p) => p.id === id),
      recommendedFor: (section) => (section ? ranked.filter((r) => r.section === section) : ranked),
      topMatch: () => ranked.find((p) => p.why(profile)) ?? ranked[0],
      savedIds,
      toggleSaved: (id) => setSaved((s) => (s.includes(id) ? s.filter((x) => x !== id) : [...s, id])),
    };
  }, [profile, savedIds]);

  return <C.Provider value={value}>{children}</C.Provider>;
}

export function useWellness() {
  const ctx = useContext(C);
  if (!ctx) throw new Error("useWellness must be used inside WellnessProvider");
  return ctx;
}

// Label maps for the onboarding UI
export const GOAL_LABELS: Record<Goal, { label: string; emoji: string }> = {
  active: { label: "Stay active", emoji: "🏃" },
  eat: { label: "Eat healthier", emoji: "🥗" },
  stress: { label: "Reduce stress", emoji: "🧘" },
  medical: { label: "Find medical support", emoji: "🏥" },
  discover: { label: "Discover wellness places", emoji: "🗺️" },
};
export const INTEREST_LABELS: Record<Interest, { label: string; emoji: string }> = {
  basketball: { label: "Basketball", emoji: "🏀" },
  football: { label: "Football", emoji: "⚽" },
  tennis: { label: "Tennis", emoji: "🎾" },
  running: { label: "Running", emoji: "🏃" },
  gym: { label: "Gym", emoji: "🏋️" },
  yoga: { label: "Yoga / Meditation", emoji: "🧘" },
  walking: { label: "Walking", emoji: "🚶" },
  cafes: { label: "Healthy cafes", emoji: "☕" },
};
export const DIET_LABELS: Record<Diet, { label: string; emoji: string }> = {
  diabetic: { label: "Diabetic-friendly meals", emoji: "🩺" },
  "low-sugar": { label: "Low sugar", emoji: "🍯" },
  "high-protein": { label: "High protein", emoji: "🥩" },
  vegetarian: { label: "Vegetarian", emoji: "🥬" },
  weight: { label: "Weight management", emoji: "⚖️" },
  heart: { label: "Heart-friendly", emoji: "❤️" },
  none: { label: "No specific preference", emoji: "✨" },
};
export const MOOD_LABELS: Record<Mood, { label: string; emoji: string }> = {
  calm: { label: "Calm", emoji: "😌" },
  stressed: { label: "Stressed", emoji: "😣" },
  tired: { label: "Tired", emoji: "😴" },
  anxious: { label: "Anxious", emoji: "😰" },
  motivated: { label: "Motivated", emoji: "💪" },
  "fresh-air": { label: "Need fresh air", emoji: "🌬️" },
};
Wire it into the root in src/routes/__root.tsx:

import { WellnessProvider } from "@/lib/wellness-store";
// ...inside RootComponent:
<QueryClientProvider client={queryClient}>
  <WellnessProvider>
    <Outlet />
  </WellnessProvider>
</QueryClientProvider>
6. Shell Components
src/components/PhoneShell.tsx
Centers content in a 420px-wide rounded "phone frame" on desktop; full-bleed on mobile. Use it on splash, onboarding, and as the wrapper of the /app layout.

import type { ReactNode } from "react";

export function PhoneShell({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen w-full bg-warm flex items-center justify-center md:p-6">
      <div className="w-full md:w-[420px] h-screen md:h-[860px] md:rounded-[2.5rem] bg-background md:shadow-[var(--shadow-lift)] overflow-hidden flex flex-col md:border md:border-border">
        {children}
      </div>
    </div>
  );
}
src/components/BottomNav.tsx
Five tabs. Use <Link> from @tanstack/react-router and check useRouterState().location.pathname to highlight the active tab.

Tabs: Home → /app/home, Map → /app/map, Heartbeat → /app/heartbeat, Saved → /app/saved, Profile → /app/profile. Icons from lucide-react (Home, Map, Heart, Bookmark, User).

src/components/SelectableCard.tsx
Toggle card for onboarding. Props: selected: boolean; emoji: string; label: string; onClick: () => void. When selected: border-primary bg-primary/5 ring-2 ring-primary/20; otherwise plain border-border bg-card.

src/components/PlaceCard.tsx
Already shown in the original codebase. Renders emoji avatar, name, category, distance, the dynamic place.why(profile) reason in italic accent color, tags as pills, and "View Details →".

7. Routes
/ — src/routes/index.tsx
Splash inside PhoneShell: TenaSpace logo, the pitch line, an "I'm new here" CTA → /onboarding, and a small "Skip to demo" → /app/home.

/onboarding — 4-step flow
Step 1 Goals (multi) → Step 2 Interests (multi) → Step 3 Diet (multi, with "none" exclusive) → Step 4 Mood (single). Progress bar at top using bg-sunrise. Continue button bottom-fixed. The "none" diet is mutually exclusive with all other diets.

/app layout — src/routes/app.tsx
<PhoneShell>
  <div className="flex-1 flex flex-col min-h-0">
    <div className="flex-1 overflow-y-auto"><Outlet /></div>
    <BottomNav />
  </div>
</PhoneShell>
/app/home
Sunrise hero with "Selam 👋 Your wellness plan is ready" + mood line. Below: "Today's Wellness Match" floating card (overlaps the hero by -mt-5). Then "Recommended For You" (top 3 with a why reason), then themed sections: Move Your Body 🏃 / Eat Well 🥗 / Calm Your Mind 🧘 / Health Support Nearby 🏥 — each showing 2 cards from that section. Footer line: "TenaSpace turns your city into a personalized wellness map."

/app/place/$id — place detail with AI music ⭐ key feature
Tall sunrise hero with tena-pattern overlay, back + bookmark buttons. Below: "Why recommended" card, "Suggested actions" 2×2 grid (Start 5-minute breathing, Play calm background sound, Get directions, Save place).

For places where place.musicPrompt is defined (and/or place.section === "calm"), wire the Play calm background sound button to the AI music player described in Section 8. For other places, gray out / hide that action.

/app/map
Mockup. Category filter chips (All, Move, Eat, Calm, Health). A stylized map background (gradient + dotted pattern) with absolute-positioned colored pins, then a list of nearby places below.

/app/heartbeat
Big circular button labeled "Hold to measure". On press: add animate-pulse class, count for 5 s, then reveal a fake BPM between 64–82 with a friendly insight ("Your heart rate is in a relaxed range — perfect for a slow walk at Meskel Square").

/app/saved
List the places whose ids are in savedIds. Empty state: "No saved places yet — tap the bookmark on any place to keep it here."

/app/profile
Show the chosen goals/interests/diets/mood as pill chips. "Edit my profile" button → /onboarding. "Reset profile" calls reset() then routes to /.

8. AI Background Music Feature ⭐
8.1 What it does
On a place detail screen, when a user taps Play calm background sound:

The button enters a "Composing…" state with a subtle pulse.
The client POSTs to /api/generate-music with the place's musicPrompt.
The server route calls ElevenLabs Music API and streams the MP3 bytes back.
The client receives a Blob, creates an object URL, and plays it via new Audio(url).
A mini player appears with Pause / Resume and a volume slider.
8.2 Server route — src/routes/api/generate-music.ts
import { createFileRoute } from "@tanstack/react-router";
import { z } from "zod";

const Body = z.object({
  prompt: z.string().min(8).max(500),
  durationSeconds: z.number().min(10).max(60).optional().default(30),
});

export const Route = createFileRoute("/api/generate-music")({
  server: {
    handlers: {
      POST: async ({ request }) => {
        const key = process.env.ELEVENLABS_API_KEY;
        if (!key) {
          return new Response(JSON.stringify({ error: "ELEVENLABS_API_KEY is not configured" }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
          });
        }

        const parsed = Body.safeParse(await request.json());
        if (!parsed.success) {
          return new Response(JSON.stringify({ error: parsed.error.message }), {
            status: 400,
            headers: { "Content-Type": "application/json" },
          });
        }

        const upstream = await fetch("https://api.elevenlabs.io/v1/music", {
          method: "POST",
          headers: {
            "xi-api-key": key,
            "Content-Type": "application/json",
            "Accept": "audio/mpeg",
          },
          body: JSON.stringify({
            prompt: parsed.data.prompt,            // NOTE: Music API uses `prompt`, not `text`
            duration_seconds: parsed.data.durationSeconds,
          }),
          signal: request.signal,
        });

        if (!upstream.ok || !upstream.body) {
          const errText = await upstream.text().catch(() => "");
          return new Response(JSON.stringify({ error: errText || `Upstream ${upstream.status}` }), {
            status: upstream.status,
            headers: { "Content-Type": "application/json" },
          });
        }

        return new Response(upstream.body, {
          headers: {
            "Content-Type": "audio/mpeg",
            "Cache-Control": "no-store",
          },
        });
      },
    },
  },
});
8.3 Client player — drop into app.place.$id.tsx
import { useEffect, useRef, useState } from "react";
import { Play, Pause, Loader2, Music } from "lucide-react";

function AiMusicPlayer({ prompt }: { prompt: string }) {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const urlRef = useRef<string | null>(null);
  const [state, setState] = useState<"idle" | "loading" | "playing" | "paused" | "error">("idle");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    return () => {
      audioRef.current?.pause();
      if (urlRef.current) URL.revokeObjectURL(urlRef.current);
    };
  }, []);

  async function generateAndPlay() {
    try {
      setError(null);
      setState("loading");
      const res = await fetch("/api/generate-music", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt, durationSeconds: 30 }),
      });
      if (!res.ok) throw new Error((await res.json().catch(() => ({}))).error ?? `Failed (${res.status})`);
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      urlRef.current = url;
      const audio = new Audio(url);
      audio.loop = true;
      audio.volume = 0.7;
      audioRef.current = audio;
      audio.onended = () => setState("idle");
      await audio.play();
      setState("playing");
    } catch (e) {
      setError(e instanceof Error ? e.message : "Could not generate music");
      setState("error");
    }
  }

  function togglePause() {
    const a = audioRef.current;
    if (!a) return;
    if (a.paused) { a.play(); setState("playing"); }
    else { a.pause(); setState("paused"); }
  }

  if (state === "idle" || state === "error") {
    return (
      <button
        onClick={generateAndPlay}
        className="flex flex-col items-start gap-2 rounded-2xl bg-card border border-border p-3 text-left hover:shadow-[var(--shadow-soft)] transition-shadow w-full"
      >
        <Music className="h-5 w-5 text-primary" />
        <span className="text-xs font-semibold leading-tight">Play calm background sound</span>
        {error && <span className="text-[10px] text-destructive">{error}</span>}
      </button>
    );
  }

  return (
    <div className="rounded-2xl bg-calm border border-border p-3 col-span-2">
      <div className="flex items-center gap-3">
        <button
          onClick={state === "loading" ? undefined : togglePause}
          className="h-10 w-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center shadow-[var(--shadow-soft)]"
        >
          {state === "loading" ? <Loader2 className="h-4 w-4 animate-spin" /> :
           state === "playing" ? <Pause className="h-4 w-4" /> : <Play className="h-4 w-4" />}
        </button>
        <div className="flex-1 min-w-0">
          <div className="text-xs font-semibold">AI calming soundscape</div>
          <div className="text-[10px] text-muted-foreground truncate">
            {state === "loading" ? "Composing your soundscape…" : "Looping in the background"}
          </div>
        </div>
      </div>
    </div>
  );
}
Inside the place detail's "Suggested actions" grid, replace the placeholder "Play calm background sound" action with:

{place.musicPrompt
  ? <AiMusicPlayer prompt={place.musicPrompt} />
  : <Action emoji="🎵" label="Play calm background sound" disabled />}
8.4 Setup steps in Cursor / local dev
Get an ElevenLabs API key from https://elevenlabs.io/app/settings/api-keys (Music generation is a paid tier — confirm your plan includes it).
Add to .env (or .env.local) at the project root:
ELEVENLABS_API_KEY=sk_...
Add .env* to .gitignore.
The server route reads process.env.ELEVENLABS_API_KEY at runtime — no client exposure.
Run dev: bun install && bun run dev (or npm/pnpm equivalent).
Open the app, complete onboarding, navigate to Meskel Square Walking Route, Entoto Quiet Viewpoint, or Ghion Garden Meditation Lawn, and tap Play calm background sound. First request takes ~10–20 s while ElevenLabs composes the track; subsequent loops are instant.
8.5 Notes & gotchas
Parameter name: ElevenLabs Music API uses prompt. The Sound Effects API uses text. Do not mix them up.
Binary safety: on the client, always use res.blob() / res.arrayBuffer() — never res.json() for raw MP3.
No btoa(...spread): if you ever base64-encode the audio server-side, use Buffer.from(buf).toString("base64") — spreading large Uint8Arrays into String.fromCharCode causes stack overflows.
Cost: each tap costs an ElevenLabs music credit. Consider caching by place.id in a Map<string, Blob> so the same place reuses the first generation in the same session.
Loop seamlessly: 30 s tracks set with audio.loop = true work fine for ambient pads; if you hear a click on the wrap, ask the model for "long sustained tail, ambient pad ending" in the prompt.
8.6 Optional enhancement: per-mood prompt blending
Compose the prompt from the user's current profile.mood to make it even more personalized:

const moodHint: Record<NonNullable<WellnessProfile["mood"]>, string> = {
  calm: "soft and steady",
  stressed: "slow tempo with deep breathing pace, very gentle",
  tired: "warm low-energy pads, restful",
  anxious: "grounding low drone with slow heartbeat tempo",
  motivated: "subtle uplift, hopeful chords",
  "fresh-air": "open airy textures, distant wind",
};

const fullPrompt =
  place.musicPrompt +
  (profile.mood ? ` Mood adaptation: ${moodHint[profile.mood]}.` : "");
Send fullPrompt to /api/generate-music.

9. SEO / Head Tags
Each route file exports head() returning unique meta. Example:

export const Route = createFileRoute("/app/home")({
  head: () => ({ meta: [
    { title: "Your wellness plan · TenaSpace" },
    { name: "description", content: "Personalized wellness recommendations across Addis Ababa." },
  ]}),
  component: Home,
});
Splash page should set <title>TenaSpace — your personal wellness map of Addis Ababa</title>.

10. Acceptance Checklist for Cursor
 All 12 routes from Section 3 exist and render.
 Onboarding writes to context; /app/home reflects choices (mood badge, "why" reasons).
 PhoneShell renders a phone frame at ≥ md, full-screen on mobile.
 BottomNav highlights the active tab.
 Place detail shows different "Why recommended" text per user profile.
 Tapping bookmark toggles persistence in savedIds; /app/saved reflects it.
 Heartbeat screen pulses and shows a randomized BPM after the hold.
 /api/generate-music returns audio/mpeg when ELEVENLABS_API_KEY is set, and 500 with a JSON error when it isn't.
 On Meskel / Entoto / Ghion, tapping "Play calm background sound" shows Composing → mini player → audible loop.
 No raw color literals in components — only design tokens.
 No tailwind.config.js — all theming lives in src/styles.css.
11. One-paragraph "show the judges" script
"Hi, I'm using TenaSpace. I told it I want to reduce stress, I love walking, I'm diabetic, and I feel anxious today. On the home screen it instantly built a plan around me — it surfaced Meskel Square's walking route because of my mood, Kazanchis Healthy Bowl because of my diet, and Entoto Viewpoint because I'm anxious. I tap Entoto, and it doesn't just describe the place — it composes a calming Ethiopian-flute soundscape with AI in real time, looped for as long as I want to read. TenaSpace turns your city into a personalized wellness map."

End of spec. Hand this file to Cursor and ask: "Implement the project described in this markdown spec. Start with package.json, then src/styles.css, then src/lib/wellness-store.tsx, then routes in the order listed in Section 3. Verify each acceptance item in Section 10."