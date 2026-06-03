import { fetchCuratedWellnessFeedResult } from "@/lib/get-wellness-feed";
import type { WellnessProfile } from "@/lib/wellness";

function jsonError(status: number, error: string) {
  return Response.json({ error }, { status });
}

function parseProfile(body: unknown): WellnessProfile | null {
  if (!body || typeof body !== "object") return null;

  const goals = "goals" in body && Array.isArray(body.goals) ? body.goals : null;
  const interests = "interests" in body && Array.isArray(body.interests) ? body.interests : null;
  const diets = "diets" in body && Array.isArray(body.diets) ? body.diets : null;
  const mood = "mood" in body ? body.mood : null;

  if (!goals || !interests || !diets) return null;

  return {
    goals: goals.filter((value): value is WellnessProfile["goals"][number] => typeof value === "string"),
    interests: interests.filter(
      (value): value is WellnessProfile["interests"][number] => typeof value === "string",
    ),
    diets: diets.filter((value): value is WellnessProfile["diets"][number] => typeof value === "string"),
    mood: typeof mood === "string" ? (mood as WellnessProfile["mood"]) : null,
  };
}

export async function POST(request: Request) {
  const profile = parseProfile(await request.json().catch(() => null));
  if (!profile) {
    return jsonError(400, "Invalid wellness profile payload.");
  }

  const result = await fetchCuratedWellnessFeedResult(profile);
  if (!result.feed) {
    return jsonError(
      503,
      `Could not curate wellness feed. ${result.error ?? "No data to display."}`,
    );
  }

  return Response.json(result.feed, {
    headers: { "Cache-Control": "no-store" },
  });
}
