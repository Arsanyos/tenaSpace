# TenaSpace Mobile (Flutter)

The mobile counterpart of the TenaSpace Next.js prototype in the repository
root: onboarding → Groq-curated wellness feed → place details with a live map
and AI/curated background sound → city map.

It is a **thin client**. All AI calls (Groq curation, Hugging Face audio) go
through the existing Next.js API routes so no API key ever ships in the app.

```
┌──────────────┐  POST /api/wellness-feed   ┌──────────────┐   Groq
│ Flutter app  │ ─────────────────────────▶ │ Next.js API  │ ─────────▶
│ (this folder)│  POST /api/generate-sound  │  (../app)    │   Hugging Face
│              │ ◀───────────────────────── │              │ ◀─────────
└──────────────┘  GET  /audio/*.mp3         └──────────────┘
```

## Run it

```sh
# 1. Start the web app / API from the repository root (needs GROQ_API_KEY etc.)
npm run dev                     # http://localhost:3000

# 2. Run the Flutter app
cd mobile
flutter pub get
flutter run                     # iOS simulator: talks to http://localhost:3000
                                # Android emulator: auto-uses http://10.0.2.2:3000

# Physical device → point it at your machine's LAN IP
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000

# No backend at all (interview / offline demo): bundled Addis Ababa feed,
# curated tracks unavailable, AI sound falls back to the synthesised loop
flutter run --dart-define=USE_MOCK_API=true

# No simulator yet? Preview in a desktop browser against the REAL API.
# Next.js allows CORS from localhost:8080 (see next.config.ts), so keep that port.
flutter run -d web-server --web-port 8080 --web-hostname localhost --release
# → open http://localhost:8080 in Safari/Chrome (npm run dev must be running)
```

Verify:

```sh
flutter analyze        # 0 issues
flutter test           # 70 unit + widget tests
```

> Debug builds allow plain-HTTP to reach the local server
> (`usesCleartextTraffic` on Android, `NSAllowsArbitraryLoads` on iOS).
> Point `API_BASE_URL` at an HTTPS origin and remove both before shipping.

## Architecture

Feature-first layout, each feature split into the same four layers
(the "Riverpod architecture" popularised by Andrea Bizzotto):

```
lib/
├── main.dart                     bootstrap: SharedPreferences → ProviderScope
├── app.dart                      MaterialApp.router + theme
├── core/
│   ├── config/app_config.dart    --dart-define → AppConfig (API_BASE_URL, USE_MOCK_API)
│   ├── network/api_client.dart   thin http wrapper, ApiException with server messages
│   ├── routing/app_router.dart   go_router: /, /onboarding, /preparing, /feed, /map, /place/:id
│   ├── storage/                  sharedPreferencesProvider (overridden at startup)
│   ├── theme/                    TenaColors / TenaText / gradients & shadows (ported from Tailwind)
│   └── widgets/                  SunriseSurface, TenaPattern, PillButton, InfoCard, …
└── features/
    ├── profile/      domain: WellnessProfile + option enums · data: ProfileStorage · application: ProfileController
    ├── onboarding/   application: OnboardingController (draft + step) · presentation: Splash, 4-step flow, Transition
    ├── feed/         domain: WellnessFeed/Place parsing · data: repository (API | mock) + FeedCache · application: FeedController
    ├── place/        domain: PlaceDetail, audio config, fallback WAV · application: SoundPlayerController, saved places
    ├── map/          domain: MapPlace · application: MapScreenController + derived providers · presentation: flutter_map
    └── shell/        StatefulShellRoute scaffold + bottom nav
```

| Layer            | Contains                                             | Knows about                 |
| ---------------- | ---------------------------------------------------- | --------------------------- |
| **domain**       | immutable models, enums, pure functions, JSON parse  | nothing else                |
| **data**         | repositories, storage, API calls                     | domain, core/network        |
| **application**  | Riverpod `Notifier`s / derived `Provider`s           | domain, data                |
| **presentation** | widgets; `ref.watch` state, `ref.read(...notifier)`  | application, domain, theme  |

## State management — Riverpod 3 (hand-written, no codegen)

| Provider                                 | Type                                   | Why it is shaped this way                                                                                                              |
| ---------------------------------------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `profileControllerProvider`              | `NotifierProvider`                     | The **committed** profile. Only changes on "Create My Wellness Map" / "Explore as Guest".                                              |
| `onboardingControllerProvider`           | `NotifierProvider.autoDispose`         | **Draft** profile + step. Disposed when leaving onboarding → next visit starts clean. Keeping draft ≠ committed stops mid-onboarding Groq calls. |
| `feedControllerProvider`                 | `AsyncNotifierProvider` (kept alive)   | `ref.watch(profile)` makes the feed *derived state*: commit a profile → it re-curates. Kept alive so tab switches never refetch. `retry: null` → explicit "Try again". |
| `placeDetailProvider(id)`                | `Provider.autoDispose.family`          | Pure derivation from feed + profile (falls back to the on-disk cache after a cold start). No I/O, trivially testable.                    |
| `savedPlacesControllerProvider`          | `NotifierProvider<Set<String>>`        | Bookmarks persisted to SharedPreferences.                                                                                             |
| `isPlaceSavedProvider(id)`               | family + `.select`                     | A widget rebuilds only when *its* place flips, not when any bookmark changes.                                                          |
| `soundPlayerControllerProvider(id)`      | `NotifierProvider.autoDispose.family`  | Owns one `AudioPlayer`; `ref.onDispose` stops audio when the screen is popped. `AudioPlayer` is injected via a factory provider for tests. |
| `mapScreenControllerProvider` + derived  | autoDispose Notifier + `Provider`s     | Filter/selection shared by three sibling widgets (preview, list, sheet) — the point where `setState` stops scaling.                    |
| `wellnessFeedRepositoryProvider`         | `Provider<interface>`                  | Swapped for a mock by `USE_MOCK_API`; overridden with fakes in tests. Same trick for `soundRepositoryProvider` and `apiClientProvider`. |

Other patterns worth pointing at in an interview:

* **Async bootstrap via override** — `main()` awaits `SharedPreferences` once and injects it with
  `sharedPreferencesProvider.overrideWithValue(prefs)`; the un-overridden provider throws on purpose.
* **`ref.mounted` after every `await`** in notifiers (Riverpod 3 throws if a disposed `Ref` is used).
* **Sealed classes + exhaustive `switch`** — `ProfileOption` (enums implement it), `CachedAudio`, and
  `AsyncValue` pattern-matching in `FeedScreen` (`AsyncData(:final value)` / `AsyncError(:final error)` / `_`).
* **Automatic retry disabled** at the root `ProviderScope` (`retry: (_, __) => null`) because the product
  wants an explicit retry button, and the same setting in `createContainer()` keeps tests deterministic.
* **`StatefulShellRoute.indexedStack`** keeps each tab's scroll position; the detail route is pushed on the
  root navigator so it covers the bottom bar like the web's full-screen page.
* **`TransitionScreen` pre-warms the feed** (`ref.read(feedControllerProvider)`) during the 1.1 s animation —
  the Flutter equivalent of `router.prefetch("/feed")`.
* **In-memory audio** — generated clips are served to `just_audio` through a custom `StreamAudioSource`
  (`BytesAudioSource`), no temp files. If generation fails the app plays a 6-second WAV synthesised in Dart
  (`buildFallbackAmbientWav`) — a byte-for-byte port of the web's fallback.

## Web ⇄ Flutter concept map

| Web (Next.js / React)                                 | Flutter (this app)                                                  |
| ----------------------------------------------------- | ------------------------------------------------------------------- |
| `app/page.tsx`, `app/feed/page.tsx`, `app/place/[id]` | `GoRoute`s in `core/routing/app_router.dart`                        |
| `useState` for profile draft / step                   | `OnboardingController` (`Notifier<OnboardingState>`)                |
| `localStorage` / `sessionStorage`                     | `SharedPreferences` behind `ProfileStorage`, `FeedCache`, `SavedPlacesStorage` |
| `fetch('/api/wellness-feed')` in a `useEffect`        | `FeedController.build()` (`AsyncNotifier`) → `AsyncValue` in the UI |
| Tailwind tokens (`bg-sunrise`, `text-ink`, …)         | `TenaColors`, `TenaGradients`, `TenaText`, `SunriseSurface`         |
| `.tena-pattern` CSS background                        | `TenaPattern` `CustomPainter`                                       |
| Leaflet + OpenStreetMap tiles                         | `flutter_map` + OpenStreetMap tiles (`WellnessMap`)                 |
| `<audio>` element + `URL.createObjectURL(blob)`       | `just_audio` + `BytesAudioSource`                                   |
| `SheetModal` (`fixed inset-0` dialog)                 | `showModalBottomSheet` (`WellnessMapSheet`)                         |
| `window.open(googleMapsLink)`                         | `url_launcher` → `launchUrl(..., LaunchMode.externalApplication)`   |
| `lucide-react` icons                                  | Material `Icons`                                                    |

## Tests

```
test/
├── core/api_client_test.dart              MockClient: headers, error extraction, transport failures
├── features/profile/domain                JSON round-trip, unknown values ignored, structural equality
├── features/feed/domain                   parser mirrors server validation (drop / cap / dedupe / order)
├── features/feed/application              FeedController with fake HTTP: success, 503, refresh, re-curate on profile change
├── features/feed/presentation             FeedScreen loading → data, empty state → "Try again", card → route
├── features/onboarding/application        toggles, single-select mood, gating, back/next
├── features/onboarding/presentation       Splash CTAs + routing, 4-step flow on a phone-sized viewport
├── features/place/domain                  audio config resolution, mood prompts, walking estimate, default actions, WAV header
├── features/place/application             SoundPlayerController with a mocked AudioPlayer: cache, fallback, static track, pause/volume
└── features/place/presentation            PlaceDetailScreen rendering, Save toggle, not-found state
```

`test/helpers/test_helpers.dart` has the shared bits: `createContainer()` (retry off + auto-dispose),
`fakePreferences()`, `baseOverrides()`, `jsonResponse()` (UTF-8 — emoji!), `usePhoneViewport()`.

## Known gaps / next steps

* Heartbeat, Saved and Profile tabs are disabled placeholders — same as the web today. `Saved` would be a
  ~40-line screen over `savedPlacesControllerProvider` + `feedControllerProvider`.
* The `web` target is only for a quick look (`flutter run -d chrome --dart-define=USE_MOCK_API=true`);
  the real targets are iOS/Android. `just_audio` byte streaming uses its local proxy, which is mobile/desktop only.
* Curated meditation tracks stream from `../public/audio` via the Next.js server instead of being bundled
  (≈22 MB) — so they are unavailable in `USE_MOCK_API` mode.
