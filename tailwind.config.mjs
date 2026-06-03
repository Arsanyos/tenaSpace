/** @type {import('tailwindcss').Config} */
const config = {
  theme: {
    extend: {
      colors: {
        cream: "#fffaf3",
        ink: "#172132",
        muted: "#746b62",
        orange: "#f5783f",
        "orange-soft": "#fff0df",
        clay: "#bd6c46",
        sage: "#4f9467",
        stone: "#eadfd2",
        chip: "#faead7",
      },
      backgroundImage: {
        sunrise:
          "radial-gradient(circle at 20% 10%, rgba(255, 234, 178, 0.75), transparent 28%), linear-gradient(150deg, #ffd98f 0%, #ff985f 48%, #cf6448 100%)",
      },
      boxShadow: {
        soft: "0 8px 22px -14px rgba(80, 44, 25, 0.28)",
        lift: "0 18px 42px -26px rgba(80, 44, 25, 0.42)",
      },
    },
  },
};

export default config;
