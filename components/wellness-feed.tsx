import { WellnessPlaceCard } from "@/components/wellness-place-card";
import type { WellnessFeedData } from "@/lib/mock-wellness-feed";

interface WellnessFeedProps {
  feed: WellnessFeedData;
  onViewDetails?: (placeId: string) => void;
}

export function WellnessFeed({ feed, onViewDetails }: WellnessFeedProps) {
  return (
    <>
      <div className="mx-auto w-full max-w-5xl px-5 sm:px-10 lg:px-14">
        <WellnessPlaceCard place={feed.featured} variant="featured" onViewDetails={onViewDetails} />
      </div>

      <section className="mx-auto w-full max-w-5xl space-y-8 px-5 pb-32 pt-8 sm:px-10 lg:px-14">
        {feed.sections.map((section) => (
          <div key={section.id}>
            <h2 className="mb-4 text-xl font-black text-ink">{section.title}</h2>
            <div className="grid gap-4 lg:grid-cols-2">
              {section.places.map((place) => (
                <WellnessPlaceCard
                  key={place.id}
                  place={place}
                  onViewDetails={onViewDetails}
                />
              ))}
            </div>
          </div>
        ))}
        <p className="pb-2 text-center text-sm text-muted">
          TenaSpace turns your city into a personalized wellness map.
        </p>
      </section>
    </>
  );
}
