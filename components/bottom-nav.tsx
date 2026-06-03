"use client";

import { Bookmark, Heart, Home, Map, User } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";

const tabs = [
  { label: "Home", href: "/feed", icon: Home },
  { label: "Map", href: "/map", icon: Map },
  { label: "Heartbeat", href: null, icon: Heart },
  { label: "Saved", href: null, icon: Bookmark },
  { label: "Profile", href: null, icon: User },
] as const;

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed inset-x-0 bottom-0 z-50 mx-auto grid grid-cols-5 border-t border-stone bg-white/95 px-3 pb-4 pt-3 shadow-[0_-18px_40px_-30px_rgba(80,44,25,0.55)] backdrop-blur sm:bottom-6 sm:max-w-5xl sm:rounded-b-[2rem] sm:px-6 lg:max-w-6xl xl:max-w-7xl">
      {tabs.map(({ label, href, icon: Icon }) => {
        const active = href !== null && pathname === href;
        const className = `flex flex-col items-center gap-1 text-xs font-semibold sm:text-sm ${
          active ? "text-orange" : "text-muted"
        }`;

        if (href === null) {
          return (
            <button key={label} type="button" disabled className={`${className} cursor-not-allowed opacity-50`}>
              <Icon size={24} strokeWidth={2} />
              {label}
            </button>
          );
        }

        return (
          <Link key={label} href={href} className={className} aria-current={active ? "page" : undefined}>
            <Icon size={24} strokeWidth={active ? 2.5 : 2} />
            {label}
          </Link>
        );
      })}
    </nav>
  );
}
