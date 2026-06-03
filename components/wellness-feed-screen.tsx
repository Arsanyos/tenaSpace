"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { BottomNav } from "@/components/bottom-nav";
import { WellnessFeed } from "@/components/wellness-feed";
import type { WellnessFeedData } from "@/lib/mock-wellness-feed";
import type { WellnessProfile } from "@/lib/wellness";
import { saveCuratedWellnessFeed } from "@/lib/wellness-feed-storage";

interface WellnessFeedScreenProps {
  profile: WellnessProfile;
}

type FeedStatus = "loading" | "ready" | "empty";

async function fetchCuratedFeed(
  profile: WellnessProfile,
  signal: AbortSignal,
): Promise<WellnessFeedData | null> {
  const response = await fetch("/api/wellness-feed", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(profile),
    signal,
  });

  if (!response.ok) return null;

  const curated = (await response.json()) as WellnessFeedData;
  if (!curated?.featured || !Array.isArray(curated.sections)) return null;

  return curated;
}

export function WellnessFeedScreen({ profile }: WellnessFeedScreenProps) {
  const router = useRouter();
  const [feed, setFeed] = useState<WellnessFeedData | null>(null);
  const [status, setStatus] = useState<FeedStatus>("loading");
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    let cancelled = false;

    async function load() {
      setStatus("loading");
      setFeed(null);

      try {
        const curated = await fetchCuratedFeed(profile, controller.signal);
        if (cancelled) return;

        if (curated) {
          saveCuratedWellnessFeed(curated);
          setFeed(curated);
          setStatus("ready");
        } else {
          setStatus("empty");
        }
      } catch (error) {
        if (cancelled) return;
        if (error instanceof DOMException && error.name === "AbortError") return;
        setStatus("empty");
      }
    }

    void load();

    return () => {
      cancelled = true;
      controller.abort();
    };
  }, [profile, reloadKey]);

  return (
    <div className="flex min-h-0 w-full flex-1 flex-col overflow-hidden bg-cream">
      <section className="relative z-0 shrink-0 bg-sunrise tena-pattern px-6 pb-6 pt-9 text-white sm:px-10 sm:pb-48 sm:pt-12 lg:px-14">
        <div className="mx-auto max-w-5xl">
          <p className="font-semibold text-orange/85">Selam 👋</p>
          <h1 className="mt-3 max-w-2xl text-3xl font-black leading-tight text-white sm:text-5xl">
            Your wellness plan is ready
          </h1>
          <p className="mt-2 text-sm text-white sm:text-base">
            {status === "loading"
              ? "Groq is curating your places..."
              : status === "ready"
                ? "Curated for your goals, interests, and mood."
                : "We could not load your curated plan."}
          </p>
        </div>
      </section>

      <section className="min-h-0 flex-1 overflow-y-auto overscroll-y-contain">
        {status === "loading" ? (
          <div className="mx-auto flex max-w-5xl flex-col items-center justify-center px-6 py-24 text-center">
            <div className="h-10 w-10 animate-spin rounded-full border-2 border-orange/30 border-t-orange" />
            <p className="mt-4 text-sm font-semibold text-muted">Curating your wellness feed...</p>
          </div>
        ) : null}

        {status === "empty" ? (
          <div className="mx-auto flex max-w-5xl flex-col items-center justify-center px-6 py-24 text-center">
            <p className="text-2xl" aria-hidden>
              🌫️
            </p>
            <h2 className="mt-4 text-xl font-black text-ink">No data to display</h2>
            <p className="mt-2 max-w-sm text-sm text-muted">
              Groq could not curate suggestions right now. Check your API key and try again.
            </p>
            <button
              type="button"
              onClick={() => setReloadKey((key) => key + 1)}
              className="mt-6 rounded-full bg-orange px-6 py-3 text-sm font-black text-white shadow-soft transition hover:opacity-90"
            >
              Try again
            </button>
          </div>
        ) : null}

        {status === "ready" && feed ? (
          <WellnessFeed
            feed={feed}
            onViewDetails={(placeId) => {
              router.push(`/place/${placeId}`);
            }}
          />
        ) : null}
      </section>
      <BottomNav />
    </div>
  );
}
