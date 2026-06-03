import { FloatingPill } from "@/components/floating-pill";

interface SplashScreenProps {
  onStart: () => void;
  onGuest: () => void;
}

export function SplashScreen({ onStart, onGuest }: SplashScreenProps) {
  return (
    <section className="bg-sunrise tena-pattern flex min-h-0 flex-1 flex-col overflow-y-auto overscroll-y-contain px-7 py-10 text-white sm:px-10 lg:px-14 lg:py-12">
      <div className="mx-auto flex w-full max-w-6xl shrink-0 items-center gap-4 text-orange">
        <div className="grid h-9 w-9 place-items-center rounded-xl bg-white/20 shadow-soft backdrop-blur sm:h-11 sm:w-11">
          <span className="sm:text-xl">🌅</span>
        </div>
        <span className="font-bold tracking-wide sm:text-lg">TenaSpace</span>
      </div>

      <div className="mx-auto mt-10 w-full max-w-6xl space-y-10 lg:mt-12 lg:grid lg:grid-cols-[1.05fr_0.95fr] lg:items-center lg:gap-8">
        <div>
          <h1 className="max-w-3xl text-5xl font-black leading-[1.08] tracking-tight text-white sm:text-6xl lg:text-7xl">
            Your wellness,
            <br />
            your city,
            <br />
            your way.
          </h1>
          <p className="mt-7 max-w-xl text-lg font-medium leading-8 text-white sm:text-xl sm:leading-9">
            Discover courts, clinics, calm spaces, healthy meals, and wellness experiences —
            personalized for you.
          </p>
        </div>

        <div className="relative min-h-[19rem] sm:min-h-[22rem] lg:min-h-[32rem]">
          <FloatingPill className="left-0 top-0 rotate-[-7deg]" emoji="🏀" title="Basketball Court" text="1.8 km · Bole" />
          <FloatingPill className="right-0 top-10 rotate-[5deg]" emoji="🥗" title="Healthy Restaurant" text="Diabetic-friendly" />
          <FloatingPill className="left-7 top-40 rotate-[-3deg] sm:left-16" emoji="🧘" title="Meditation Space" text="Entoto · Quiet" />
          <FloatingPill className="right-2 top-36 rotate-[3deg] sm:top-56" emoji="🏥" title="Clinic Nearby" text="Megenagna · 1.5 km" />
        </div>
      </div>

      <div className="relative z-10 mx-auto mt-10 w-full max-w-6xl shrink-0 space-y-5 pb-8 text-center lg:mt-12 lg:grid lg:grid-cols-[1fr_auto_auto] lg:items-center lg:gap-4 lg:space-y-0 lg:pb-10 lg:text-left">
        <p className="text-sm text-white/70">TenaSpace turns your city into a personalized wellness map.</p>
        <button
          type="button"
          onClick={onStart}
          className="cta-start-btn w-full rounded-full px-6 py-5 text-lg font-black lg:w-auto lg:min-w-72"
        >
          Start Your Wellness Profile
        </button>
        <button
          type="button"
          onClick={onGuest}
          className="font-bold text-white/80 [touch-action:manipulation]"
        >
          Explore as Guest
        </button>
      </div>
    </section>
  );
}
