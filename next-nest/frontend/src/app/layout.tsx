import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "All Gujarat Vankar Samaj Matrimony",
  description: "Official Web Portal for All Gujarat Vankar Samaj Matrimony",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full antialiased font-sans">
      <body>{children}</body>
    </html>
  );
}
