"use client";

import { ArrowLeft } from "lucide-react";
import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { PhoneShell } from "@/components/phone-shell";
import { PlaceDetailScreen } from "@/components/place-detail-screen";
import {
  createPlaceDetailFromCuratedPlace,
  type WellnessPlaceDetailData,
} from "@/lib/get-place-detail";
import { findCuratedFeedPlace } from "@/lib/wellness-feed-storage";
import { loadWellnessProfile } from "@/lib/wellness-profile-storage";

export default function PlacePage() {
  const router = useRouter();
  const params = useParams<{ id: string | string[] }>();
  const placeIdParam = params.id;
  const placeId = Array.isArray(placeIdParam) ? placeIdParam[0] : placeIdParam;
  const [detail, setDetail] = useState<WellnessPlaceDetailData | null>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      const place = placeId ? findCuratedFeedPlace(placeId) : null;
      const profile = loadWellnessProfile();
      setDetail(place ? createPlaceDetailFromCuratedPlace(place, profile) : null);
      setLoaded(true);
    }, 0);

    return () => window.clearTimeout(timer);
  }, [placeId]);

  return (
    <PhoneShell>
      <div className="flex min-h-0 flex-1 flex-col">
        {!loaded ? (
          <section className="flex flex-1 items-center justify-center px-6 text-center">
            <p className="text-sm font-semibold text-muted">Loading place details...</p>
          </section>
        ) : detail ? (
          <PlaceDetailScreen detail={detail} onBack={() => router.back()} />
        ) : (
          <section className="flex flex-1 flex-col items-center justify-center gap-4 px-6 text-center">
            <h1 className="text-2xl font-black text-ink">Place not found</h1>
            <p className="max-w-md text-sm text-muted">
              We could not find that place in your wellness feed. Try opening details from the home
              cards again.
            </p>
            <button
              type="button"
              onClick={() => router.push("/feed")}
              className="inline-flex items-center gap-2 rounded-full bg-orange px-5 py-3 text-sm font-black text-white"
            >
              <ArrowLeft size={16} />
              Back to feed
            </button>
          </section>
        )}
      </div>
    </PhoneShell>
  );
}
