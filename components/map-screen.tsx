"use client";

import { Maximize2 } from "lucide-react";
import { useCallback, useMemo, useState } from "react";
import { BottomNav } from "@/components/bottom-nav";
import { SheetModal } from "@/components/sheet-modal";
import { WellnessMap } from "@/components/wellness-map";
import type { MapPlace } from "@/lib/map-places";
import type { WellnessSectionId } from "@/lib/mock-wellness-feed";
import { recommendedPlaces, type WellnessProfile } from "@/lib/wellness";
import { loadWellnessProfile } from "@/lib/wellness-profile-storage";

const SECTION_FILTERS: Array<{ id: "all" | WellnessSectionId; label: string }> = [
  { id: "all", label: "All" },
  { id: "move", label: "Move" },
  { id: "eat", label: "Eat" },
  { id: "calm", label: "Calm" },
  { id: "health", label: "Health" },
];

interface MapScreenProps {
  places: MapPlace[];
}

export function MapScreen({ places }: MapScreenProps) {
  const [profile] = useState<WellnessProfile>(() => loadWellnessProfile());
  const [sectionFilter, setSectionFilter] = useState<"all" | WellnessSectionId>("all");
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [mapModalOpen, setMapModalOpen] = useState(false);

  const highlightedIds = useMemo(() => {
    return new Set(recommendedPlaces(profile).slice(0, 5).map((place) => place.id));
  }, [profile]);

  const filteredPlaces = useMemo(
    () =>
      sectionFilter === "all" ? places : places.filter((place) => place.section === sectionFilter),
    [places, sectionFilter],
  );

  const handleSelectPlace = useCallback((id: string) => {
    setSelectedId(id);
  }, []);

  const openMapModal = useCallback(() => {
    setMapModalOpen(true);
  }, []);

  const mapProps = {
    places: filteredPlaces,
    highlightedIds,
    selectedId,
    onSelectPlace: handleSelectPlace,
  };

  return (
    <div className="flex min-h-0 w-full flex-1 flex-col overflow-hidden bg-cream">
      <header className="shrink-0 border-b border-stone bg-white/80 px-5 py-4 backdrop-blur sm:px-10 lg:px-14">
        <h1 className="text-xl font-black text-ink sm:text-2xl">Wellness map</h1>
        <p className="mt-1 text-sm text-muted">Explore places across Addis Ababa</p>
        <div className="mt-4 flex flex-wrap gap-2">
          {SECTION_FILTERS.map((filter) => (
            <button
              key={filter.id}
              type="button"
              onClick={() => {
                setSectionFilter(filter.id);
                setSelectedId(null);
              }}
              className={`rounded-full px-4 py-2 text-sm font-bold transition ${
                sectionFilter === filter.id
                  ? "bg-orange text-white shadow-soft"
                  : "bg-chip text-ink hover:bg-orange-soft"
              }`}
            >
              {filter.label}
            </button>
          ))}
        </div>
      </header>

      <div className="shrink-0 px-5 py-4 sm:px-10 lg:px-14">
        <button
          type="button"
          onClick={openMapModal}
          aria-label="Open full screen map"
          className="apple-map-preview group relative block w-full text-left"
        >
          <div className="apple-map-frame h-[11.5rem] overflow-hidden sm:h-[12.5rem]">
            <div className="pointer-events-none h-full w-full">
              <WellnessMap
                {...mapProps}
                mapKey="preview"
                interactive={false}
                showZoomControls={false}
              />
            </div>
          </div>
          <span className="apple-map-preview-chip">
            <Maximize2 size={14} strokeWidth={2.25} aria-hidden />
            Tap to expand
          </span>
        </button>
      </div>

      <section className="min-h-0 flex-1 overflow-y-auto border-t border-stone bg-white/90 px-5 py-4 pb-28 sm:px-10 lg:px-14">
        <h2 className="text-sm font-black uppercase tracking-[0.14em] text-clay">Nearby</h2>
        <ul className="mt-3 space-y-2">
          {filteredPlaces.map((place) => (
            <li key={place.id}>
              <button
                type="button"
                onClick={() => {
                  handleSelectPlace(place.id);
                  setMapModalOpen(true);
                }}
                className={`flex w-full items-center gap-3 rounded-2xl border px-4 py-3 text-left transition ${
                  selectedId === place.id
                    ? "border-orange bg-orange-soft"
                    : "border-stone bg-white hover:border-orange/40"
                }`}
              >
                <span className="text-2xl">{place.emoji}</span>
                <span className="min-w-0 flex-1">
                  <span className="block truncate font-bold text-ink">{place.name}</span>
                  <span className="block text-xs text-muted">
                    {place.category} · {place.distanceKm} km
                    {highlightedIds.has(place.id) ? " · For you" : ""}
                  </span>
                </span>
              </button>
            </li>
          ))}
        </ul>
      </section>

      <SheetModal
        open={mapModalOpen}
        onClose={() => setMapModalOpen(false)}
        title="Wellness map"
        subtitle="Addis Ababa"
        bodyClassName="flex min-h-0 flex-col"
      >
        <div className="apple-map-frame apple-map-frame--expanded mx-3 mb-4 h-[min(68vh,32rem)] sm:mx-4">
          <WellnessMap {...mapProps} mapKey="expanded" interactive showZoomControls />
        </div>
      </SheetModal>

      <BottomNav />
    </div>
  );
}
