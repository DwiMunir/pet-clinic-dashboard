// This file is kept for backward compatibility
// The routing configuration is now in src/i18n/routing.ts
import { routing } from "./i18n/routing";

export const locales = routing.locales;
export type Locale = (typeof locales)[number];
export const defaultLocale = routing.defaultLocale;
