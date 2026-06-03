import { MapScreen } from "@/components/map-screen";
import { PhoneShell } from "@/components/phone-shell";
import { getMapPlaces } from "@/lib/get-map-places";

export default async function MapPage() {
  const places = await getMapPlaces();

  return (
    <PhoneShell>
      <div className="flex min-h-0 flex-1 flex-col">
        <MapScreen places={places} />
      </div>
    </PhoneShell>
  );
}
