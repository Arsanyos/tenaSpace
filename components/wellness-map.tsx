"use client";

import dynamic from "next/dynamic";
import type { MapPlace } from "@/lib/map-places";

const WellnessMapClient = dynamic(
  () => import("@/components/wellness-map-client").then((mod) => mod.WellnessMapClient),
  {
    ssr: false,
    loading: () => (
      <div className="flex h-full w-full items-center justify-center bg-chip text-sm font-medium text-muted">
        Loading map…
      </div>
    ),
  },
);

interface WellnessMapProps {
  places: MapPlace[];
  highlightedIds: Set<string>;
  selectedId: string | null;
  onSelectPlace: (id: string) => void;
  interactive?: boolean;
  showZoomControls?: boolean;
  /** Stable key so preview vs modal maps mount as separate Leaflet instances */
  mapKey?: string;
}

export function WellnessMap({ mapKey, ...props }: WellnessMapProps) {
  return <WellnessMapClient key={mapKey} {...props} />;
}
