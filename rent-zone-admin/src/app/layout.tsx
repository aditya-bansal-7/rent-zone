import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Rent Zone — Marketplace Studio",
  description: "A connected workspace for running the Rent Zone fashion rental marketplace.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  );
}
