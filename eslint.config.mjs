import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = [
  // The Flutter app under mobile/ has its own toolchain (`flutter analyze`).
  { ignores: ["mobile/**"] },
  ...nextVitals,
  ...nextTs,
];

export default eslintConfig;
