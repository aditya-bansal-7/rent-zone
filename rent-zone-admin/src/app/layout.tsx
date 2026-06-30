import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Rent Zone Admin",
  description: "Admin console for the Rent Zone clothing rental marketplace",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  );
}
