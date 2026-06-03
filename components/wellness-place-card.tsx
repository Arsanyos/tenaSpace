import type { WellnessPlaceCardData } from "@/lib/mock-wellness-feed";

export type WellnessPlaceCardVariant = "default" | "featured";

interface WellnessPlaceCardProps {
  place: WellnessPlaceCardData;
  variant?: WellnessPlaceCardVariant;
  className?: string;
  onViewDetails?: (placeId: string) => void;
}

export function WellnessPlaceCard({
  place,
  variant = "default",
  className = "",
  onViewDetails,
}: WellnessPlaceCardProps) {
  const isFeatured = variant === "featured";

  return (
    <article
      className={`rounded-[1.8rem] bg-white p-5 shadow-lift ring-1 ring-stone sm:p-6 ${className}`}
    >
      {isFeatured ? (
        <p className="mb-4 text-xs font-black uppercase tracking-[0.18em] text-clay">
          ✨ Today&apos;s wellness match
        </p>
      ) : null}

      <div className="flex items-start gap-4 sm:gap-5">
        <div
          className={`grid h-16 w-16 shrink-0 place-items-center rounded-full text-3xl sm:h-[4.5rem] sm:w-[4.5rem] ${
            isFeatured ? "bg-sunrise text-white" : "bg-orange-soft"
          }`}
        >
          {place.emoji}
        </div>
        <div className="min-w-0 flex-1">
          <h3
            className={`font-black leading-snug text-balance break-words text-ink ${
              isFeatured ? "text-xl sm:text-2xl" : "text-lg sm:text-xl"
            }`}
          >
            {place.name}
          </h3>
          <p className="mt-1 text-pretty text-sm text-muted">
            {place.category} · {place.distanceKm} km away
          </p>
        </div>
      </div>

      <p className="mt-5 text-pretty italic text-sage">{place.recommendation}</p>

      {!isFeatured && place.tags && place.tags.length > 0 ? (
        <div className="mt-4 flex flex-wrap gap-2">
          {place.tags.map((tag) => (
            <span key={tag} className="rounded-full bg-chip px-3 py-1 text-xs font-bold text-clay">
              {tag}
            </span>
          ))}
        </div>
      ) : null}

      {onViewDetails ? (
        <button
          type="button"
          onClick={() => onViewDetails(place.id)}
          className="mt-4 text-sm font-black text-orange transition hover:text-clay"
        >
          {isFeatured ? "Open match details →" : "View Details →"}
        </button>
      ) : null}
    </article>
  );
}
