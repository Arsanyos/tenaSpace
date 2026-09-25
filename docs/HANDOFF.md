# TenaSpace — Engineering handoff

Context for anyone (human or coding agent) picking up this repository. It captures what
was built, why it was built that way, what is verified, and what is known to be broken —
so the next session does not have to rediscover it.

_Last updated: 2026-09-25, after PR #3._

---

## 1. What this repo is

**TenaSpace** is a hackathon prototype: a personalised wellness map for Addis Ababa.
A 4-step onboarding (goals → lifestyle → diet → mood) feeds an LLM that curates real
Addis places into four sections (Move / Eat / Calm / Health); each place has a detail
view with a map, "why recommended", suggested actions and background sound.

Two clients share one backend:

| Client | Where | Stack |
| --- | --- | --- |
| Web | repo root | Next.js 16 (App Router) · React 19 · Tailwind 4 · Leaflet |
| Mobile | `mobile/` | Flutter 3.47 · Dart 3.13 · Riverpod 3 · go_router · flutter_map · just_audio |

The **mobile app is a thin client** over the web app's API routes, so API keys never
ship inside the binary:

```
Flutter ──POST /api/wellness-feed──▶ Next.js ──▶ Groq (LLM curation)
        ──POST /api/generate-sound─▶         ──▶ Hugging Face (text-to-audio)   ⚠ see §5
        ──GET  /audio/*.mp3────────▶ public/audio (curated meditation tracks)
```

The mobile app was built with a **Flutter interview** in mind: architectural choices are
deliberately explainable (see §4) and `mobile/README.md` doubles as interview notes.

## 2. History (all merged into `main`)

| PR | Summary |
| --- | --- |
| #1 | `feat(mobile)` — the Flutter app (146 files); root `eslint.config.mjs` / `tsconfig.json` ignore `mobile/` |
| #2 | `fix(web)` — CORS headers for browser clients on `/api/*` + `/audio/*`; Groq default model `llama-3.1-8b-instant` → `openai/gpt-oss-20b` (Llama was retired by Groq, which had made the feed route return 503 for everyone) |
| #3 | `fix(web)` — `max_completion_tokens: 4096` + `reasoning_effort: "low"` so gpt-oss's hidden reasoning no longer truncates the feed JSON (`json_validate_failed`) |

## 3. Layout & key files

### Web (root)
| Path | Role |
| --- | --- |
| `app/page.tsx` | splash + onboarding + transition (client state) |
| `app/feed/page.tsx`, `app/place/[id]/page.tsx`, `app/map/page.tsx` | screens |
| `app/api/wellness-feed/route.ts` → `lib/get-wellness-feed.ts` | Groq curation; strict server-side validation of the LLM JSON (`parseCuratedFeed`) |
| `app/api/generate-sound/route.ts` | Hugging Face text-to-audio proxy (**broken upstream**, §5) |
| `lib/audio-config.ts`, `lib/get-place-detail.ts` | per-place audio config + detail view-model (ported 1:1 to Dart) |
| `next.config.ts` | CORS via `headers()` — one rule per allowed origin matched on the request's `Origin` header; defaults to `http://localhost:8080` / `http://127.0.0.1:8080`; extend with `CORS_ALLOWED_ORIGINS` (comma-separated) |
| `public/audio/*.mp3` | three curated meditation tracks (~22 MB) served to both clients |

Environment (`.env.local`, never committed): `GROQ_API_KEY` (required), `GROQ_MODEL`,
`GROQ_REASONING_EFFORT`, `HUGGINGFACE_API_KEY`, `HUGGINGFACE_AUDIO_MODEL`,
`HUGGINGFACE_AUDIO_ENDPOINT_URL`, `CORS_ALLOWED_ORIGINS`.

### Mobile (`mobile/`)
Feature-first, four layers per feature — `domain` (pure models/parsers) → `data`
(repositories, storage) → `application` (Riverpod notifiers/derived providers) →
`presentation` (widgets). Shared code in `core/{config,network,routing,storage,theme,widgets}`.

`mobile/README.md` has the full architecture table, a provider-by-provider rationale,
a web ⇄ Flutter concept map and the test map. Highlights:

* `--dart-define=API_BASE_URL=…` (default `http://localhost:3000`; Android emulator
  auto-uses `http://10.0.2.2:3000`) and `--dart-define=USE_MOCK_API=true` (fully
  offline: bundled feed in `features/feed/data/mock_wellness_feed.dart`).
* Riverpod 3, hand-written (no codegen). Committed profile vs. onboarding *draft*;
  `feedControllerProvider` is an `AsyncNotifier` derived from the committed profile,
  kept alive across tabs, with auto-retry disabled in favour of an explicit "Try again".
* AI audio bytes are played from memory through a custom `StreamAudioSource`; any
  failure falls back to a Dart-synthesised ambient loop (`buildFallbackAmbientWav`).
* Dev-only network exceptions: Android `usesCleartextTraffic="true"`, iOS
  `NSAllowsArbitraryLoads` / `NSAllowsLocalNetworking`. **Remove before shipping over HTTPS.**
* Bottom nav: Home and Map are live; Heartbeat, Saved and Profile are disabled
  placeholders (same as the web).

## 4. Decisions and why (interview material)

* **Riverpod over Bloc/Provider** — compile-safe, derived state without boilerplate,
  trivially testable through provider overrides.
* **Thin client** — mirrors a real mobile + backend split; no secrets in the app.
* **No codegen** — fewer moving parts for a prototype; every provider is readable inline.
* **Committed vs. draft profile** — toggling an onboarding option must not re-run the
  multi-second Groq call; only "Create My Wellness Map" commits.
* **Feed provider kept alive** — switching Home ⇄ Map must not refetch.
* **Auto-retry disabled globally** (`ProviderScope(retry: …)`) — the product wants an
  explicit retry button; tests become deterministic.
* **`ref.mounted` after every `await`** — Riverpod 3 throws when a disposed `Ref` is used.
* **Sealed `ProfileOption` implemented by four enums** — one generic onboarding UI,
  exhaustive `switch` in the controller.
* Riverpod 3 gotcha: `Override` / `ProviderBase` types are exported from
  `package:flutter_riverpod/misc.dart`, not the main import.
* gpt-oss on Groq: hidden reasoning shares the completion budget — always set
  `max_completion_tokens` generously and `reasoning_effort: "low"` for structured output.

## 5. Known issues / open threads

1. **`/api/generate-sound` is broken upstream.** `api-inference.huggingface.co` no
   longer resolves (Hugging Face moved to
   `https://router.huggingface.co/hf-inference/models/<model>`), `cvssp/audioldm2` is
   no longer served by any inference provider, and a fine-grained HF token needs the
   *"Make calls to Inference Providers"* permission. At the time of writing the only warm
   text-to-audio model was `stabilityai/stable-audio-3-medium`. The mobile app handles
   the resulting 500 gracefully (fallback loop), so demos still work. Fix = new base URL
   (or `HUGGINGFACE_AUDIO_ENDPOINT_URL`) + a served model + token permission.
2. `openai/gpt-oss-20b` occasionally returns sparse sections (e.g. only `health`). The
   parser tolerates it; a prompt nudge or single retry-on-sparse would tighten it.
3. Saved / Profile / Heartbeat tabs are placeholders. `Saved` is ~40 lines over
   `savedPlacesControllerProvider` + `feedControllerProvider`.
4. No CI for `mobile/` yet (`flutter analyze && flutter test`).
5. Curated `.mp3`s are served by Next.js rather than bundled, so they are unavailable in
   `USE_MOCK_API` mode.
6. Groq free tier rate-limits rapid retries (`429 rate_limit_exceeded`); wait ~10 s.

## 6. Running & verifying

```sh
# Backend
npm install && npm run dev                     # http://localhost:3000 (reads .env.local)

# Mobile — device / simulator
cd mobile && flutter pub get && flutter run    # add --dart-define=API_BASE_URL=http://<lan-ip>:3000 for a phone

# Mobile — browser preview without a simulator (keep port 8080: it is the CORS-allowed origin)
flutter run -d web-server --web-port 8080 --web-hostname localhost --release

# Mobile — fully offline demo
flutter run --dart-define=USE_MOCK_API=true

# Checks
(cd mobile && dart format lib test && flutter analyze && flutter test)   # 0 issues, 70 tests
npx eslint . && npx tsc --noEmit
```

Common trip-ups: it is `flutter pub get`, not `pub get`; if Next.js falls back to 3001
because 3000 is taken, either free the port or pass
`--dart-define=API_BASE_URL=http://localhost:3001`.

## 7. Conventions

* Small, single-purpose PRs with a **Verification** section in the description.
* Run the checks in §6 before every commit.
* Commit trailer for agent-assisted commits:
  `Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>`

## 8. Suggested next steps

1. GitHub Actions workflow for `mobile/**` (analyze + test on PRs).
2. Implement the Saved tab.
3. Repair `/api/generate-sound` per §5.1.
4. Delete the merged `arsanyos-flutter-mobile-app` branch on origin.
