"use client";

import { ArrowLeft, Bookmark, Clock3, MapPinned, Sparkles } from "lucide-react";
import { useMemo, useState } from "react";
import { AiSoundPlayer } from "@/components/ai-sound-player";
import { WellnessMap } from "@/components/wellness-map";
import type { WellnessPlaceDetailData } from "@/lib/get-place-detail";

interface PlaceDetailScreenProps {
  detail: WellnessPlaceDetailData;
  onBack: () => void;
}

const SAVED_PLACE_IDS_KEY = "tenaspace-saved-place-ids";

function readSavedPlaceIds(): string[] {
  if (typeof window === "undefined") return [];

  try {
    const raw = localStorage.getItem(SAVED_PLACE_IDS_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter((entry): entry is string => typeof entry === "string");
  } catch {
    return [];
  }
}

function writeSavedPlaceIds(ids: string[]) {
  if (typeof window === "undefined") return;
  localStorage.setItem(SAVED_PLACE_IDS_KEY, JSON.stringify(ids));
}

export function PlaceDetailScreen({ detail, onBack }: PlaceDetailScreenProps) {
  const [savedIds, setSavedIds] = useState<string[]>(() => readSavedPlaceIds());
  const saved = savedIds.includes(detail.id);

  const mapPlaces = useMemo(() => (detail.mapPlace ? [detail.mapPlace] : []), [detail.mapPlace]);
  const highlightedIds = useMemo(() => new Set(mapPlaces.map((place) => place.id)), [mapPlaces]);

  const directionsLink = detail.mapPlace
    ? `https://www.google.com/maps/search/?api=1&query=${detail.mapPlace.lat},${detail.mapPlace.lng}`
    : null;

  function toggleSaved() {
    const nextIds = saved
      ? savedIds.filter((placeId) => placeId !== detail.id)
      : Array.from(new Set([...savedIds, detail.id]));

    setSavedIds(nextIds);
    writeSavedPlaceIds(nextIds);
  }

  return (
    <div className="flex min-h-0 w-full flex-1 flex-col overflow-hidden bg-cream">
      <header className="bg-sunrise tena-pattern shrink-0 px-5 pb-6 pt-5 text-white sm:px-10 lg:px-14">
        <div className="mx-auto max-w-5xl">
          <div className="flex items-center justify-between gap-3">
            <button
              type="button"
              onClick={onBack}
              className="inline-flex items-center gap-2 rounded-full bg-white/25 px-3 py-1.5 text-sm font-semibold text-white transition hover:bg-white/35"
            >
              <ArrowLeft size={16} />
              Back
            </button>
            <button
              type="button"
              onClick={toggleSaved}
              className={`inline-flex items-center gap-2 rounded-full px-3 py-1.5 text-sm font-semibold transition ${
                saved ? "bg-white text-ink" : "bg-white/25 text-white hover:bg-white/35"
              }`}
            >
              <Bookmark size={16} className={saved ? "fill-current" : ""} />
              {saved ? "Saved" : "Save"}
            </button>
          </div>

          <div className="mt-5 flex items-start gap-4">
            <span className="grid h-16 w-16 shrink-0 place-items-center rounded-full bg-white/25 text-3xl">
              {detail.emoji}
            </span>
            <div className="min-w-0">
              <h1 className="text-3xl font-black leading-tight text-white sm:text-4xl">{detail.name}</h1>
              <p className="mt-1 text-sm text-white/90">
                {detail.category} · {detail.distanceKm} km away
              </p>
            </div>
          </div>
        </div>
      </header>

      <section className="min-h-0 flex-1 space-y-4 overflow-y-auto px-5 pb-10 pt-5 sm:px-10 lg:px-14">
        <div className="mx-auto max-w-5xl rounded-3xl border border-stone bg-white p-5 shadow-soft">
          <p className="text-xs font-black uppercase tracking-[0.14em] text-clay">Why recommended</p>
          <p className="mt-2 text-base text-ink">{detail.whyRecommended}</p>
        </div>

        <div className="mx-auto grid w-full max-w-5xl gap-4 lg:grid-cols-[1.15fr_0.85fr]">
          <div className="rounded-3xl border border-stone bg-white p-4 shadow-soft">
            <p className="mb-3 text-xs font-black uppercase tracking-[0.14em] text-clay">Map location</p>
            {detail.mapPlace ? (
              <div className="apple-map-frame h-52 overflow-hidden">
                <WellnessMap
                  places={mapPlaces}
                  highlightedIds={highlightedIds}
                  selectedId={detail.id}
                  onSelectPlace={() => undefined}
                  interactive={false}
                  showZoomControls={false}
                  mapKey={`detail-${detail.id}`}
                />
              </div>
            ) : (
              <p className="rounded-2xl bg-chip px-3 py-8 text-center text-sm text-muted">
                Map coordinates are not available for this place yet.
              </p>
            )}
          </div>

          <div className="rounded-3xl border border-stone bg-white p-4 shadow-soft">
            <p className="text-xs font-black uppercase tracking-[0.14em] text-clay">Visit snapshot</p>
            <div className="mt-3 space-y-3">
              <p className="flex items-center gap-2 text-sm font-semibold text-ink">
                <Clock3 size={16} className="text-orange" />
                {detail.durationMinutes ? `${detail.durationMinutes} min estimated walk` : "Duration not available"}
              </p>
              <p className="flex items-center gap-2 text-sm font-semibold text-ink">
                <Sparkles size={16} className="text-orange" />
                {detail.bestTime ? `Best time: ${detail.bestTime}` : "Open recommendation anytime"}
              </p>
              <p className="flex items-start gap-2 text-sm font-semibold text-ink">
                <MapPinned size={16} className="mt-0.5 text-orange" />
                {detail.mapPlace ? `${detail.mapPlace.lat.toFixed(4)}, ${detail.mapPlace.lng.toFixed(4)}` : "Coordinates unavailable"}
              </p>
            </div>
          </div>
        </div>

        <div className="mx-auto w-full max-w-5xl rounded-3xl border border-stone bg-white p-5 shadow-soft">
          <p className="text-xs font-black uppercase tracking-[0.14em] text-clay">Suggested actions</p>
          <div className="mt-3 grid gap-3 sm:grid-cols-2">
            <button
              type="button"
              className="rounded-2xl border border-stone bg-chip px-4 py-3 text-left text-sm font-semibold text-ink"
            >
              Start 5-minute breathing
            </button>

            {directionsLink ? (
              <a
                href={directionsLink}
                target="_blank"
                rel="noreferrer"
                className="rounded-2xl border border-stone bg-chip px-4 py-3 text-left text-sm font-semibold text-ink transition hover:border-orange/40"
              >
                Get directions
              </a>
            ) : (
              <button
                type="button"
                disabled
                className="cursor-not-allowed rounded-2xl border border-stone bg-chip px-4 py-3 text-left text-sm font-semibold text-muted opacity-70"
              >
                Get directions
              </button>
            )}

            {detail.audioConfig ? (
              <div className="sm:col-span-2">
                <AiSoundPlayer placeId={detail.id} config={detail.audioConfig} />
              </div>
            ) : (
              <button
                type="button"
                disabled
                className="cursor-not-allowed rounded-2xl border border-stone bg-chip px-4 py-3 text-left text-sm font-semibold text-muted opacity-70 sm:col-span-2"
              >
                AI sound is unavailable for this activity
              </button>
            )}
          </div>
        </div>

        <div className="mx-auto flex w-full max-w-5xl flex-wrap gap-2 pb-4">
          {detail.tags.map((tag) => (
            <span key={tag} className="rounded-full bg-chip px-3 py-1 text-xs font-bold text-clay">
              {tag}
            </span>
          ))}
        </div>
      </section>
    </div>
  );
}
