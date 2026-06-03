"use client";

import { ArrowLeft } from "lucide-react";
import type { Dispatch, SetStateAction } from "react";
import { SelectableCard } from "@/components/selectable-card";
import {
  type Diet,
  type Goal,
  type Interest,
  type Mood,
  type WellnessProfile,
} from "@/lib/wellness";

const goalOptions: Array<{ value: Goal; emoji: string; label: string }> = [
  { value: "active", emoji: "🏃", label: "Stay active" },
  { value: "eat", emoji: "🥗", label: "Eat healthier" },
  { value: "stress", emoji: "🧘", label: "Reduce stress" },
  { value: "medical", emoji: "🏥", label: "Find medical support" },
  { value: "discover", emoji: "🗺️", label: "Discover wellness places" },
];

const interestOptions: Array<{ value: Interest; emoji: string; label: string }> = [
  { value: "basketball", emoji: "🏀", label: "Basketball" },
  { value: "football", emoji: "⚽", label: "Football" },
  { value: "tennis", emoji: "🎾", label: "Tennis" },
  { value: "running", emoji: "🏃", label: "Running" },
  { value: "gym", emoji: "🏋️", label: "Gym" },
  { value: "yoga", emoji: "🧘", label: "Yoga / Meditation" },
  { value: "walking", emoji: "🚶", label: "Walking" },
  { value: "cafes", emoji: "☕", label: "Healthy cafes" },
];

const dietOptions: Array<{ value: Diet; emoji: string; label: string }> = [
  { value: "diabetic", emoji: "🩺", label: "Diabetic-friendly meals" },
  { value: "low-sugar", emoji: "🍯", label: "Low sugar" },
  { value: "high-protein", emoji: "🥩", label: "High protein" },
  { value: "vegetarian", emoji: "🥬", label: "Vegetarian" },
  { value: "weight", emoji: "⚖️", label: "Weight management" },
  { value: "heart", emoji: "❤️", label: "Heart-friendly" },
  { value: "none", emoji: "✨", label: "No specific preference" },
];

const moodOptions: Array<{ value: Mood; emoji: string; label: string }> = [
  { value: "calm", emoji: "😌", label: "Calm" },
  { value: "stressed", emoji: "😣", label: "Stressed" },
  { value: "tired", emoji: "😴", label: "Tired" },
  { value: "anxious", emoji: "😰", label: "Anxious" },
  { value: "motivated", emoji: "💪", label: "Motivated" },
  { value: "fresh-air", emoji: "💨", label: "Need fresh air" },
];

function toggleItem<T>(items: T[], value: T) {
  return items.includes(value) ? items.filter((item) => item !== value) : [...items, value];
}

interface OnboardingScreenProps {
  profile: WellnessProfile;
  step: number;
  setStep: (step: number) => void;
  setProfile: Dispatch<SetStateAction<WellnessProfile>>;
  onBack: () => void;
  onDone: () => void;
}

export function OnboardingScreen({
  profile,
  step,
  setStep,
  setProfile,
  onBack,
  onDone,
}: OnboardingScreenProps) {
  const steps = [
    {
      eyebrow: "Wellness Goal",
      title: "What do you want help with today?",
      subtitle: "Select all that apply.",
      options: goalOptions,
      values: profile.goals,
      select: (value: Goal) =>
        setProfile((current) => ({ ...current, goals: toggleItem(current.goals, value) })),
      canContinue: profile.goals.length > 0,
    },
    {
      eyebrow: "Lifestyle",
      title: "What activities match your lifestyle?",
      subtitle: "We use this to recommend the right places, not random places.",
      options: interestOptions,
      values: profile.interests,
      select: (value: Interest) =>
        setProfile((current) => ({ ...current, interests: toggleItem(current.interests, value) })),
      canContinue: profile.interests.length > 0,
    },
    {
      eyebrow: "Health & Diet",
      title: "Do you have any diet or health preferences?",
      subtitle: "TenaSpace gives wellness suggestions, not medical advice.",
      options: dietOptions,
      values: profile.diets,
      select: (value: Diet) =>
        setProfile((current) => ({ ...current, diets: toggleItem(current.diets, value) })),
      canContinue: profile.diets.length > 0,
    },
    {
      eyebrow: "Mood Check",
      title: "How are you feeling lately?",
      subtitle: "Your mood shapes today's recommendations.",
      options: moodOptions,
      values: profile.mood ? [profile.mood] : [],
      select: (value: Mood) => setProfile((current) => ({ ...current, mood: value })),
      canContinue: profile.mood !== null,
    },
  ] as const;

  const current = steps[step];
  const selectedValues = current.values as readonly string[];
  const selectCurrent = current.select as (value: string) => void;
  const progress = ((step + 1) / steps.length) * 100;

  const handleBack = () => {
    if (step === 0) {
      onBack();
      return;
    }
    setStep(step - 1);
  };

  return (
    <section className="fade-in flex h-full min-h-0 flex-1 flex-col overflow-hidden bg-cream">
      <header className="shrink-0 border-b border-stone/80 bg-cream px-5 pt-5 pb-4 sm:px-9 sm:pt-7 sm:pb-5 lg:px-12">
        <div className="relative flex items-center">
          <button
            type="button"
            onClick={handleBack}
            aria-label={`Go back. Current step is ${step + 1} of ${steps.length}.`}
            className="relative z-10 grid h-11 w-11 shrink-0 place-items-center rounded-full bg-orange-soft text-ink shadow-soft transition hover:-translate-y-0.5 hover:shadow-lift active:translate-y-0 active:scale-95"
          >
            <ArrowLeft size={20} />
          </button>
          <p className="pointer-events-none absolute inset-x-0 text-center text-sm font-medium text-muted">
            Step {step + 1} of {steps.length}
          </p>
        </div>
        <div className="mt-5 h-1.5 overflow-hidden rounded-full bg-chip sm:mt-6">
          <div className="h-full rounded-full bg-orange transition-all" style={{ width: `${progress}%` }} />
        </div>
      </header>

      <div className="shrink-0 px-5 pt-5 pb-4 sm:px-9 sm:pt-6 lg:px-12">
        <p className="text-xs font-black uppercase tracking-[0.18em] text-clay">{current.eyebrow}</p>
        <h1 className="mt-3 max-w-3xl text-3xl font-black leading-tight text-balance text-ink sm:text-4xl lg:text-5xl">
          {current.title}
        </h1>
        <p className="mt-3 max-w-2xl text-base leading-7 text-pretty text-muted sm:text-lg">
          {current.subtitle}
        </p>
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain px-5 pb-4 sm:px-9 lg:px-12">
        <div className="mx-auto flex w-full max-w-5xl flex-col gap-3 sm:grid sm:grid-cols-2 sm:gap-3.5">
          {current.options.map((option) => (
            <SelectableCard
              key={option.value}
              emoji={option.emoji}
              label={option.label}
              selected={selectedValues.includes(option.value)}
              onClick={() => selectCurrent(option.value)}
            />
          ))}
        </div>
      </div>

      <footer className="shrink-0 border-t border-stone bg-white px-5 py-4 sm:px-9 sm:py-5 lg:px-12">
        <button
          type="button"
          disabled={!current.canContinue}
          onClick={() => (step === steps.length - 1 ? onDone() : setStep(step + 1))}
          className={`mx-auto block w-full max-w-5xl rounded-full px-6 py-4 text-lg font-black text-white shadow-soft transition duration-200 sm:py-5 ${
            current.canContinue
              ? "bg-orange hover:-translate-y-1 hover:shadow-[0_22px_45px_-24px_rgba(245,120,63,0.9)] active:translate-y-0 active:scale-[0.99]"
              : "cursor-not-allowed bg-[#f8c3ad]"
          }`}
        >
          {step === steps.length - 1 ? "Create My Wellness Map" : "Continue"}
        </button>
      </footer>
    </section>
  );
}
