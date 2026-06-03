"use client";

import { X } from "lucide-react";
import { useEffect, useId, useRef, type ReactNode } from "react";

interface SheetModalProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  subtitle?: string;
  children: ReactNode;
  /** Extra classes for the scrollable / flex body region */
  bodyClassName?: string;
}

export function SheetModal({
  open,
  onClose,
  title,
  subtitle,
  children,
  bodyClassName = "",
}: SheetModalProps) {
  const titleId = useId();
  const panelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;

    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";

    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };

    window.addEventListener("keydown", onKeyDown);
    panelRef.current?.focus();

    return () => {
      document.body.style.overflow = previousOverflow;
      window.removeEventListener("keydown", onKeyDown);
    };
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-[70] flex items-end justify-center p-3 sm:items-center sm:p-6"
      role="presentation"
      onClick={onClose}
    >
      <div
        className="absolute inset-0 bg-ink/35 backdrop-blur-md transition-opacity"
        aria-hidden
      />

      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={title ? titleId : undefined}
        tabIndex={-1}
        className="apple-sheet relative flex max-h-[min(92vh,52rem)] w-full max-w-5xl flex-col overflow-hidden outline-none sm:max-h-[min(88vh,48rem)]"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="flex shrink-0 items-start justify-between gap-4 px-5 pb-3 pt-4 sm:px-6 sm:pt-5">
          <div className="min-w-0 flex-1 pt-1">
            {title ? (
              <h2 id={titleId} className="truncate text-lg font-bold tracking-tight text-ink sm:text-xl">
                {title}
              </h2>
            ) : null}
            {subtitle ? <p className="mt-0.5 text-sm text-muted">{subtitle}</p> : null}
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Close"
            className="apple-icon-button shrink-0"
          >
            <X size={18} strokeWidth={2.25} />
          </button>
        </div>

        <div className={`min-h-0 flex-1 ${bodyClassName}`}>{children}</div>
      </div>
    </div>
  );
}
