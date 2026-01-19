import type { ReactNode } from "react";
import "./globals.css";

type Props = {
  children: ReactNode;
};

// Since we have a `[locale]` segment, we don't want to apply layout styles globally
// The locale layout will handle that
export default function RootLayout({ children }: Props) {
  return children;
}
