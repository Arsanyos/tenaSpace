interface FloatingPillProps {
  className: string;
  emoji: string;
  title: string;
  text: string;
}

export function FloatingPill({ className, emoji, title, text }: FloatingPillProps) {
  return (
    <div
      aria-hidden
      className={`pointer-events-none absolute flex select-none items-center gap-3 rounded-full bg-white px-4 py-3 text-ink shadow-lift sm:px-5 sm:py-4 ${className}`}
    >
      <span className="text-2xl">{emoji}</span>
      <span>
        <span className="block text-sm font-black leading-none sm:text-base">{title}</span>
        <span className="mt-1 block text-xs text-muted sm:text-sm">{text}</span>
      </span>
    </div>
  );
}
