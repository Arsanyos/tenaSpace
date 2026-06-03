"use client";

import {
  ArrowLeft,
  Bookmark,
  CheckSquare,
  Clock3,
  Headphones,
  MapPinned,
  Menu,
  MessageSquareText,
  Phone,
  Save,
  Sparkles,
  Timer,
  Wind,
} from "lucide-react";
import { useMemo, useState } from "react";
import { AiSoundPlayer } from "@/components/ai-sound-player";
import { WellnessMap } from "@/components/wellness-map";
import type { WellnessPlaceDetailData } from "@/lib/get-place-detail";
import type { WellnessSuggestedAction } from "@/lib/mock-wellness-feed";

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

function getDefaultActions(detail: WellnessPlaceDetailData): WellnessSuggestedAction[] {
  const actions: WellnessSuggestedAction[] = [];

  if (detail.section === "move") {
    actions.push({
      type: "timer",
      label: detail.durationMinutes
        ? `Start a ${detail.durationMinutes}-minute activity`
        : "Start a short movement session",
      description: "Use this place as your next gentle movement stop.",
    });
  }

  if (detail.section === "calm") {
    actions.push({
      type: "breathing",
      label: "Start a grounding pause",
      description: "Take a few slow breaths before or after you arrive.",
    });
  }

  if (detail.section === "eat") {
    actions.push({
      type: "menu",
      label: "Review healthy order ideas",
      description: "Pick options that match your food preferences.",
    });
  }

  if (detail.section === "health") {
    actions.push({
      type: "call",
      label: "Call before visiting",
      description: "Confirm opening hours and available services.",
    });
  }

  if (detail.mapPlace) {
    actions.push({
      type: "directions",
      label: "Get directions",
      description: "Open this location in Google Maps.",
    });
  }

  if (detail.audioConfig) {
    actions.push({
      type: "audio",
      label: detail.audioConfig.label,
      description: "Use background sound while you read or unwind.",
    });
  }

  actions.push({
    type: "save",
    label: "Save this place",
    description: "Keep it in your wellness list for later.",
  });

  return actions;
}

export function PlaceDetailScreen({ detail, onBack }: PlaceDetailScreenProps) {
  const [savedIds, setSavedIds] = useState<string[]>(() => readSavedPlaceIds());
  const saved = savedIds.includes(detail.id);

  const mapPlaces = useMemo(() => (detail.mapPlace ? [detail.mapPlace] : []), [detail.mapPlace]);
  const highlightedIds = useMemo(() => new Set(mapPlaces.map((place) => place.id)), [mapPlaces]);

  const directionsLink = detail.mapPlace
    ? `https://www.google.com/maps/search/?api=1&query=${detail.mapPlace.lat},${detail.mapPlace.lng}`
    : null;

  const renderedActions = useMemo(() => {
    const actions = detail.suggestedActions.length > 0 ? detail.suggestedActions : getDefaultActions(detail);
    return actions.slice(0, 4);
  }, [detail]);

  function toggleSaved() {
    const nextIds = saved
      ? savedIds.filter((placeId) => placeId !== detail.id)
      : Array.from(new Set([...savedIds, detail.id]));

    setSavedIds(nextIds);
    writeSavedPlaceIds(nextIds);
  }

  function getActionIcon(type: WellnessSuggestedAction["type"]) {
    switch (type) {
      case "breathing":
        return Wind;
      case "directions":
        return MapPinned;
      case "audio":
        return Headphones;
      case "save":
        return Save;
      case "timer":
        return Timer;
      case "checklist":
        return CheckSquare;
      case "call":
        return Phone;
      case "menu":
        return Menu;
      case "note":
      default:
        return MessageSquareText;
    }
  }

  function renderAction(action: WellnessSuggestedAction, index: number) {
    const Icon = getActionIcon(action.type);
    const content = (
      <>
        <span className="flex items-start gap-3">
          <span className="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-white/70 text-orange shadow-soft">
            <Icon size={17} strokeWidth={2.2} />
          </span>
          <span className="min-w-0">
            <span className="block font-bold text-ink">{action.label}</span>
            {action.description ? (
              <span className="mt-0.5 block text-xs font-medium leading-relaxed text-muted">
                {action.description}
              </span>
            ) : null}
          </span>
        </span>
      </>
    );

    const className =
      "rounded-2xl border border-stone bg-chip px-4 py-3 text-left text-sm transition hover:border-orange/40 hover:bg-orange-soft";

    if (action.type === "directions" && directionsLink) {
      return (
        <a
          key={`${action.type}-${index}`}
          href={directionsLink}
          target="_blank"
          rel="noreferrer"
          className={className}
        >
          {content}
        </a>
      );
    }

    if (action.type === "save") {
      return (
        <button
          key={`${action.type}-${index}`}
          type="button"
          onClick={toggleSaved}
          className={className}
        >
          {content}
        </button>
      );
    }

    return (
      <button key={`${action.type}-${index}`} type="button" className={className}>
        {content}
      </button>
    );
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
            {renderedActions.map((action, index) => renderAction(action, index))}

            {detail.audioConfig ? (
              <div className="sm:col-span-2">
                <AiSoundPlayer placeId={detail.id} config={detail.audioConfig} />
              </div>
            ) : null}
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
