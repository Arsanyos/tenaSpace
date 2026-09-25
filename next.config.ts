import type { NextConfig } from "next";

/**
 * Browser origins allowed to call the API cross-origin.
 *
 * The Flutter app running in a browser (`flutter run -d web-server`) is served
 * from a different port than Next.js, so it needs CORS. Native iOS/Android
 * builds never hit this — CORS is a browser-only concept. Extend with
 * `CORS_ALLOWED_ORIGINS` (comma-separated) when the web app is deployed.
 */
const DEFAULT_CORS_ORIGINS = ["http://localhost:8080", "http://127.0.0.1:8080"];

const allowedOrigins = (process.env.CORS_ALLOWED_ORIGINS ?? "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean)
  .concat(DEFAULT_CORS_ORIGINS);

function corsHeaders(origin: string) {
  return [
    { key: "Access-Control-Allow-Origin", value: origin },
    { key: "Access-Control-Allow-Methods", value: "GET, POST, OPTIONS" },
    { key: "Access-Control-Allow-Headers", value: "Content-Type, Accept" },
    { key: "Access-Control-Max-Age", value: "86400" },
    { key: "Vary", value: "Origin" },
  ];
}

const nextConfig: NextConfig = {
  async headers() {
    // One rule per origin, matched with a `has` condition, so only the
    // requesting origin is echoed back (a wildcard would break `Vary`/caching
    // semantics and is not allowed alongside credentials).
    return allowedOrigins.flatMap((origin) =>
      ["/api/:path*", "/audio/:path*"].map((source) => ({
        source,
        has: [{ type: "header" as const, key: "origin", value: origin }],
        headers: corsHeaders(origin),
      })),
    );
  },
};

export default nextConfig;
