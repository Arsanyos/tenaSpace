import { MAP_PLACES, type MapPlace } from "@/lib/map-places";

/**
 * Loads map marker data on the server (App Router equivalent of getServerSideProps).
 * Replace the static return with a DB or API call when backend is ready.
 */
export async function getMapPlaces(): Promise<MapPlace[]> {
  return MAP_PLACES;
}
