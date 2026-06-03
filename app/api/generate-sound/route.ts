const MIN_PROMPT_LENGTH = 8;
const MAX_PROMPT_LENGTH = 600;
const MIN_DURATION_SECONDS = 10;
const MAX_DURATION_SECONDS = 60;
const DEFAULT_DURATION_SECONDS = 35;
const DEFAULT_AUDIO_MODEL = "cvssp/audioldm2";
const DEFAULT_INFERENCE_STEPS = 120;

interface GenerateSoundRequest {
  prompt: string;
  durationSeconds: number;
}

function jsonError(status: number, error: string) {
  return new Response(JSON.stringify({ error }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function extractProviderError(details: string): string {
  if (!details) return "";

  try {
    const parsed = JSON.parse(details) as { error?: string };
    if (typeof parsed.error === "string") return parsed.error;
  } catch {
    // Fall back to raw text when the provider returns a plain string.
  }

  return details;
}

function parseRequestBody(body: unknown): GenerateSoundRequest | null {
  if (!body || typeof body !== "object") return null;

  const prompt = "prompt" in body ? body.prompt : undefined;
  const durationRaw = "durationSeconds" in body ? body.durationSeconds : undefined;
  const durationSeconds =
    typeof durationRaw === "number" && Number.isFinite(durationRaw)
      ? Math.round(durationRaw)
      : DEFAULT_DURATION_SECONDS;

  if (
    typeof prompt !== "string" ||
    prompt.trim().length < MIN_PROMPT_LENGTH ||
    prompt.length > MAX_PROMPT_LENGTH
  ) {
    return null;
  }

  if (durationSeconds < MIN_DURATION_SECONDS || durationSeconds > MAX_DURATION_SECONDS) {
    return null;
  }

  return { prompt: prompt.trim(), durationSeconds };
}

export async function POST(request: Request) {
  const parsed = parseRequestBody(await request.json().catch(() => null));
  if (!parsed) {
    return jsonError(
      400,
      `Invalid body. Expected prompt (${MIN_PROMPT_LENGTH}-${MAX_PROMPT_LENGTH} chars) and optional durationSeconds (${MIN_DURATION_SECONDS}-${MAX_DURATION_SECONDS}).`,
    );
  }

  const apiKey = process.env.HUGGINGFACE_API_KEY;
  const model = process.env.HUGGINGFACE_AUDIO_MODEL ?? DEFAULT_AUDIO_MODEL;
  const inferenceUrl =
    process.env.HUGGINGFACE_AUDIO_ENDPOINT_URL?.trim() ||
    `https://api-inference.huggingface.co/models/${model}`;
  const inferenceSteps = Number(process.env.HUGGINGFACE_AUDIO_NUM_STEPS ?? DEFAULT_INFERENCE_STEPS);

  if (!apiKey) {
    return jsonError(
      500,
      "HUGGINGFACE_API_KEY is not configured on the server. Add it to your local .env.local.",
    );
  }

  const upstream = await fetch(inferenceUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      Accept: "audio/wav, audio/mpeg, audio/flac",
    },
    body: JSON.stringify({
      inputs: parsed.prompt,
      parameters: {
        audio_length_in_s: parsed.durationSeconds,
        num_inference_steps: Number.isFinite(inferenceSteps)
          ? Math.max(20, Math.min(250, Math.round(inferenceSteps)))
          : DEFAULT_INFERENCE_STEPS,
        num_waveforms_per_prompt: 1,
        negative_prompt: "Low quality, distorted, noisy, clipping, artifacts.",
      },
      options: {
        wait_for_model: true,
      },
    }),
    cache: "no-store",
  });

  if (!upstream.ok || !upstream.body) {
    const details = extractProviderError(await upstream.text().catch(() => ""));

    if (
      details.includes("isn't deployed by any Inference Provider") ||
      details.toLowerCase().includes("not deployed") ||
      details.toLowerCase().includes("not supported")
    ) {
      return jsonError(
        503,
        "cvssp/audioldm2 is not available on your selected Hugging Face inference backend. Deploy an Inference Endpoint for this model (or a Space API) and set HUGGINGFACE_AUDIO_ENDPOINT_URL.",
      );
    }

    return jsonError(
      upstream.status || 502,
      details || `Audio provider request failed (${upstream.status}).`,
    );
  }

  const contentType = upstream.headers.get("Content-Type") ?? "audio/wav";
  return new Response(upstream.body, {
    status: 200,
    headers: {
      "Content-Type": contentType,
      "Cache-Control": "no-store",
    },
  });
}
