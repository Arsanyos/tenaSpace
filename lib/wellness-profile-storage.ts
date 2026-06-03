import { emptyProfile, type WellnessProfile } from "@/lib/wellness";

const STORAGE_KEY = "tenaspace-wellness-profile";

export function saveWellnessProfile(profile: WellnessProfile): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(profile));
}

export function loadWellnessProfile(): WellnessProfile {
  if (typeof window === "undefined") return emptyProfile;

  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return emptyProfile;
    return JSON.parse(raw) as WellnessProfile;
  } catch {
    return emptyProfile;
  }
}

export function clearWellnessProfile(): void {
  if (typeof window === "undefined") return;
  localStorage.removeItem(STORAGE_KEY);
}
