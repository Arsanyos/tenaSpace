"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { OnboardingScreen } from "@/components/onboarding-screen";
import { PhoneShell } from "@/components/phone-shell";
import { SplashScreen } from "@/components/splash-screen";
import { TransitionScreen } from "@/components/transition-screen";
import { saveWellnessProfile } from "@/lib/wellness-profile-storage";
import { emptyProfile, type WellnessProfile } from "@/lib/wellness";

type Screen = "splash" | "onboarding";

export default function Home() {
  const router = useRouter();
  const [screen, setScreen] = useState<Screen>("splash");
  const [step, setStep] = useState(0);
  const [profile, setProfile] = useState<WellnessProfile>(emptyProfile);
  const [isTransitioning, setIsTransitioning] = useState(false);

  const goToFeed = (nextProfile: WellnessProfile) => {
    saveWellnessProfile(nextProfile);
    router.prefetch("/feed");
    setIsTransitioning(true);
    window.setTimeout(() => router.push("/feed"), 1100);
  };

  return (
    <PhoneShell>
      <div className="flex min-h-0 flex-1 flex-col">
        {screen === "splash" ? (
          <SplashScreen
            onStart={() => setScreen("onboarding")}
            onGuest={() => goToFeed(emptyProfile)}
          />
        ) : null}
        {screen === "onboarding" ? (
          <OnboardingScreen
            profile={profile}
            step={step}
            setStep={setStep}
            setProfile={setProfile}
            onBack={() => {
              setStep(0);
              setScreen("splash");
            }}
            onDone={() => goToFeed(profile)}
          />
        ) : null}
      </div>
      {isTransitioning ? <TransitionScreen /> : null}
    </PhoneShell>
  );
}
