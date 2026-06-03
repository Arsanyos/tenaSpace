"use client";

import { useState } from "react";
import { PhoneShell } from "@/components/phone-shell";
import { WellnessFeedScreen } from "@/components/wellness-feed-screen";
import { loadWellnessProfile } from "@/lib/wellness-profile-storage";
import type { WellnessProfile } from "@/lib/wellness";

export default function FeedPage() {
  const [profile] = useState<WellnessProfile>(() => loadWellnessProfile());

  return (
    <PhoneShell>
      <div className="flex min-h-0 flex-1 flex-col">
        <WellnessFeedScreen profile={profile} />
      </div>
    </PhoneShell>
  );
}
