import type { ReactNode } from "react";

interface SelectableCardProps {
  emoji: ReactNode;
  label: string;
  selected: boolean;
  onClick: () => void;
}

export function SelectableCard({ emoji, label, selected, onClick }: SelectableCardProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`flex w-full flex-col gap-3 rounded-3xl border px-5 py-4 text-left shadow-soft transition active:scale-[0.99] sm:gap-3.5 sm:px-6 sm:py-5 ${
        selected
          ? "border-orange bg-orange-soft ring-2 ring-orange/15"
          : "border-stone bg-white hover:border-orange/40"
      }`}
    >
      <span className="text-2xl leading-none sm:text-3xl">{emoji}</span>
      <span className="text-base font-bold leading-snug text-balance text-ink sm:text-lg">{label}</span>
      {selected ? (
        <span className="text-[0.68rem] font-black uppercase tracking-[0.16em] text-orange">
          Selected
        </span>
      ) : null}
    </button>
  );
}
