import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "TenaSpace",
  description: "A personalized wellness map for Addis Ababa.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
