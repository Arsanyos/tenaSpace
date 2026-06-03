"use client";

import { Loader2, Pause, Play, Volume2 } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import type { ResolvedAudioConfig } from "@/lib/audio-config";

interface AiSoundPlayerProps {
  placeId: string;
  config: ResolvedAudioConfig;
}

type PlayerState = "idle" | "loading" | "playing" | "paused" | "error";

const SESSION_AUDIO_CACHE = new Map<string, string>();
let fallbackDataUrl: string | null = null;

function writeAscii(view: DataView, offset: number, value: string) {
  for (let index = 0; index < value.length; index += 1) {
    view.setUint8(offset + index, value.charCodeAt(index));
  }
}

function makeFallbackAmbientDataUrl(): string {
  if (fallbackDataUrl) return fallbackDataUrl;

  const sampleRate = 16_000;
  const durationSeconds = 6;
  const frameCount = sampleRate * durationSeconds;
  const pcm = new Int16Array(frameCount);

  for (let frame = 0; frame < frameCount; frame += 1) {
    const t = frame / sampleRate;
    const fadeIn = Math.min(1, t / 1.2);
    const fadeOut = Math.min(1, (durationSeconds - t) / 1.2);
    const envelope = Math.min(fadeIn, fadeOut) * 0.22;
    const tone =
      Math.sin(2 * Math.PI * 174 * t) * 0.62 +
      Math.sin(2 * Math.PI * 220 * t) * 0.38 +
      Math.sin(2 * Math.PI * 0.17 * t) * 0.2;

    pcm[frame] = Math.round(Math.max(-1, Math.min(1, tone * envelope)) * 0x7fff);
  }

  const wavBuffer = new ArrayBuffer(44 + pcm.length * 2);
  const view = new DataView(wavBuffer);

  writeAscii(view, 0, "RIFF");
  view.setUint32(4, 36 + pcm.length * 2, true);
  writeAscii(view, 8, "WAVE");
  writeAscii(view, 12, "fmt ");
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, 1, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * 2, true);
  view.setUint16(32, 2, true);
  view.setUint16(34, 16, true);
  writeAscii(view, 36, "data");
  view.setUint32(40, pcm.length * 2, true);

  let dataOffset = 44;
  for (let frame = 0; frame < pcm.length; frame += 1) {
    view.setInt16(dataOffset, pcm[frame], true);
    dataOffset += 2;
  }

  let binary = "";
  const bytes = new Uint8Array(wavBuffer);
  for (let i = 0; i < bytes.length; i += 1) {
    binary += String.fromCharCode(bytes[i]);
  }

  fallbackDataUrl = `data:audio/wav;base64,${btoa(binary)}`;
  return fallbackDataUrl;
}

export function AiSoundPlayer({ placeId, config }: AiSoundPlayerProps) {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [state, setState] = useState<PlayerState>("idle");
  const [error, setError] = useState<string | null>(null);
  const [isFallbackTrack, setIsFallbackTrack] = useState(false);
  const [volume, setVolume] = useState(0.72);

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;
    audio.volume = volume;
  }, [volume]);

  useEffect(() => {
    return () => {
      audioRef.current?.pause();
      audioRef.current = null;
    };
  }, []);

  async function playUrl(url: string, loop: boolean) {
    const current = audioRef.current;
    if (current?.src !== url) {
      current?.pause();
      const audio = new Audio(url);
      audio.loop = loop;
      audio.volume = volume;
      audioRef.current = audio;
    } else if (current) {
      current.loop = loop;
      current.volume = volume;
    }

    await audioRef.current?.play();
    setState("playing");
  }

  async function startPlayback() {
    const cachedUrl = SESSION_AUDIO_CACHE.get(placeId);
    setError(null);
    setIsFallbackTrack(false);

    if (cachedUrl) {
      await playUrl(cachedUrl, config.loop);
      return;
    }

    if (config.staticSrc) {
      setState("loading");
      try {
        await playUrl(config.staticSrc, config.loop);
        SESSION_AUDIO_CACHE.set(placeId, config.staticSrc);
      } catch {
        setState("error");
        setError("Could not load the meditation track.");
      }
      return;
    }

    setState("loading");
    try {
      const controller = new AbortController();
      const timeoutId = window.setTimeout(() => controller.abort(), 35_000);
      const response = await fetch("/api/generate-sound", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          prompt: config.prompt,
          durationSeconds: config.durationSeconds,
        }),
        signal: controller.signal,
      });
      window.clearTimeout(timeoutId);

      if (!response.ok) {
        const body = await response.json().catch(() => ({}));
        const message = typeof body?.error === "string" ? body.error : `Failed to generate sound (${response.status})`;
        throw new Error(message);
      }

      const blob = await response.blob();
      const objectUrl = URL.createObjectURL(blob);
      SESSION_AUDIO_CACHE.set(placeId, objectUrl);
      await playUrl(objectUrl, config.loop);
    } catch (err) {
      const message = err instanceof Error ? err.message : "Could not generate sound";
      setError(message);

      try {
        await playUrl(makeFallbackAmbientDataUrl(), true);
        setIsFallbackTrack(true);
      } catch {
        setState("error");
      }
    }
  }

  function togglePause() {
    const audio = audioRef.current;
    if (!audio) return;

    if (audio.paused) {
      audio
        .play()
        .then(() => setState("playing"))
        .catch(() => setState("error"));
      return;
    }

    audio.pause();
    setState("paused");
  }

  if (state === "idle" || state === "error") {
    return (
      <button
        type="button"
        onClick={startPlayback}
        className="rounded-2xl border border-stone bg-white px-4 py-3 text-left transition hover:border-orange/40 hover:shadow-soft"
      >
        <span className="block text-xs font-black uppercase tracking-[0.14em] text-clay">
          {config.staticSrc ? "Background sound" : "AI sound"}
        </span>
        <span className="mt-1 block text-sm font-bold text-ink">{config.label}</span>
        <span className="mt-1 block text-xs text-muted">
          {config.staticSrc
            ? "Curated meditation music for this place."
            : "Generated for your activity and mood."}
        </span>
        {error ? <span className="mt-2 block text-xs font-semibold text-clay">{error}</span> : null}
      </button>
    );
  }

  return (
    <div className="rounded-2xl border border-stone bg-white p-4 shadow-soft">
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={state === "loading" ? undefined : togglePause}
          className="grid h-11 w-11 shrink-0 place-items-center rounded-full bg-orange text-white shadow-soft transition disabled:opacity-70"
          disabled={state === "loading"}
          aria-label={state === "playing" ? "Pause sound" : "Resume sound"}
        >
          {state === "loading" ? (
            <Loader2 size={18} className="animate-spin" />
          ) : state === "playing" ? (
            <Pause size={18} />
          ) : (
            <Play size={18} />
          )}
        </button>
        <div className="min-w-0 flex-1">
          <p className="text-sm font-bold text-ink">
            {isFallbackTrack
              ? "Fallback ambient track"
              : config.staticSrc
                ? "Meditation soundtrack"
                : "AI-generated soundscape"}
          </p>
          <p className="text-xs text-muted">
            {state === "loading"
              ? config.staticSrc
                ? "Loading soundtrack..."
                : "Composing your sound..."
              : isFallbackTrack
                ? "Playing local fallback loop"
                : "Looping in the background"}
          </p>
        </div>
      </div>

      <label className="mt-4 flex items-center gap-3 text-xs font-semibold text-muted">
        <Volume2 size={14} />
        <input
          type="range"
          min={0}
          max={1}
          step={0.01}
          value={volume}
          onChange={(event) => setVolume(Number(event.target.value))}
          className="w-full accent-orange"
        />
      </label>
    </div>
  );
}
