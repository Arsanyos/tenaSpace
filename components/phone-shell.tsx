import type { ReactNode } from "react";

interface PhoneShellProps {
  children: ReactNode;
}

export function PhoneShell({ children }: PhoneShellProps) {
  return (
    <main className="flex h-dvh flex-col overflow-hidden bg-[radial-gradient(circle_at_top,#ffe2bd_0%,#ffd1b7_46%,#ffc2a3_100%)] text-ink sm:px-5 sm:py-6 lg:px-8">
      <div className="mx-auto flex h-full min-h-0 w-full max-w-5xl flex-1 flex-col overflow-hidden bg-cream shadow-[0_28px_70px_-36px_rgba(120,57,28,0.65)] ring-1 ring-white/70 sm:max-h-[calc(100dvh-3rem)] sm:flex-none sm:rounded-[2rem] lg:max-w-6xl xl:max-w-7xl">
        {children}
      </div>
    </main>
  );
}
