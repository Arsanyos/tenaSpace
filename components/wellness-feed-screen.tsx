"use client";

import { useMemo } from "react";
import { useRouter } from "next/navigation";
import { BottomNav } from "@/components/bottom-nav";
import { WellnessFeed } from "@/components/wellness-feed";
import { getPersonalizedWellnessFeed } from "@/lib/get-wellness-feed";
import type { WellnessProfile } from "@/lib/wellness";

interface WellnessFeedScreenProps {
  profile: WellnessProfile;
}

export function WellnessFeedScreen({ profile }: WellnessFeedScreenProps) {
  const router = useRouter();
  const feed = useMemo(() => getPersonalizedWellnessFeed(profile), [profile]);

  return (
    <div className="flex min-h-0 w-full flex-1 flex-col overflow-hidden bg-cream">
      <section className="relative z-0 shrink-0 bg-sunrise tena-pattern px-6 pb-6 pt-9 text-white sm:px-10 sm:pb-48 sm:pt-12 lg:px-14">
        <div className="mx-auto max-w-5xl">
          <p className="font-semibold text-orange/85">Selam 👋</p>
          <h1 className="mt-3 max-w-2xl text-3xl font-black leading-tight text-white sm:text-5xl">
            Your wellness plan is ready
          </h1>
          <p className="mt-2 text-sm text-white sm:text-base">
            Based on your goals, interests, and mood.
          </p>
        </div>
      </section>
      <section className="min-h-0 flex-1 overflow-y-auto overscroll-y-contain">
        <WellnessFeed
          feed={feed}
          onViewDetails={(placeId) => {
            router.push(`/place/${placeId}`);
          }}
        />
      </section>
      <BottomNav />
    </div>
  );
}
