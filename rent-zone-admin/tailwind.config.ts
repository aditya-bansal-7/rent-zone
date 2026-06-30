import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        // Purple primary palette
        primary: {
          50:  "#faf5ff",
          100: "#f3e8ff",
          200: "#e9d5ff",
          300: "#d8b4fe",
          400: "#c084fc",
          500: "#a855f7",
          600: "#9333ea",
          700: "#7e22ce",
          800: "#6b21a8",
          900: "#581c87",
          950: "#3b0764",
          DEFAULT: "#7c3aed",
          foreground: "#ffffff",
        },
        // Neutral grays for light admin UI
        background:    "#f8f7fc",
        foreground:    "#1e1b4b",
        card:          "#ffffff",
        "card-foreground": "#1e1b4b",
        border:        "#e5e7eb",
        input:         "#e5e7eb",
        ring:          "#7c3aed",
        muted:         "#f3f4f6",
        "muted-foreground": "#6b7280",
        accent:        "#f5f3ff",
        "accent-foreground": "#7c3aed",
        // Sidebar
        sidebar: {
          bg:          "#ffffff",
          border:      "#ede9fe",
          active:      "#f5f3ff",
          "active-text": "#7c3aed",
        },
        // Status colors
        success:       "#10b981",
        warning:       "#f59e0b",
        danger:        "#ef4444",
        info:          "#3b82f6",
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
      },
      borderRadius: {
        lg: "0.75rem",
        md: "0.5rem",
        sm: "0.375rem",
        xl: "1rem",
        "2xl": "1.5rem",
      },
      boxShadow: {
        card: "0 1px 3px 0 rgba(0,0,0,0.06), 0 1px 2px -1px rgba(0,0,0,0.04)",
        "card-hover": "0 4px 6px -1px rgba(0,0,0,0.08), 0 2px 4px -2px rgba(0,0,0,0.04)",
        sidebar: "1px 0 0 0 #ede9fe",
        topbar: "0 1px 0 0 #e5e7eb",
        modal: "0 20px 60px -15px rgba(124,58,237,0.15)",
      },
      animation: {
        "fade-in": "fadeIn 0.2s ease-out",
        "slide-in": "slideIn 0.25s ease-out",
        "scale-in": "scaleIn 0.15s ease-out",
        "pulse-slow": "pulse 3s ease-in-out infinite",
      },
      keyframes: {
        fadeIn: {
          from: { opacity: "0" },
          to: { opacity: "1" },
        },
        slideIn: {
          from: { opacity: "0", transform: "translateY(-8px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
        scaleIn: {
          from: { opacity: "0", transform: "scale(0.96)" },
          to: { opacity: "1", transform: "scale(1)" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
