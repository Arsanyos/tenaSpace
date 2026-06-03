"use client";

interface TransitionScreenProps {
  title?: string;
  subtitle?: string;
}

export function TransitionScreen({
  title = "Building your wellness map",
  subtitle = "Personalizing places around you…",
}: TransitionScreenProps) {
  return (
    <div
      role="status"
      aria-live="polite"
      className="transition-screen fixed inset-0 z-[90] flex items-center justify-center overflow-hidden"
    >
      <div className="transition-orb transition-orb--one" aria-hidden />
      <div className="transition-orb transition-orb--two" aria-hidden />
      <div className="transition-orb transition-orb--three" aria-hidden />

      <div className="transition-card relative mx-6 flex w-full max-w-sm flex-col items-center gap-5 px-8 py-10 text-center">
        <div className="transition-logo grid h-16 w-16 place-items-center rounded-2xl text-3xl">
          🌅
        </div>

        <div>
          <h2 className="text-xl font-black tracking-tight text-ink">{title}</h2>
          <p className="mt-1.5 text-sm text-muted">{subtitle}</p>
        </div>

        <div className="transition-progress mt-1 h-1.5 w-40 overflow-hidden rounded-full">
          <div className="transition-progress-bar h-full rounded-full" />
        </div>
      </div>
    </div>
  );
}
