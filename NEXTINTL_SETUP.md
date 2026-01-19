# next-intl Setup Guide

This project uses `next-intl` for internationalization based on the [official documentation](https://next-intl.dev/docs/getting-started/app-router).

## File Structure

```
src/
├── i18n/
│   ├── routing.ts      # Central routing configuration
│   ├── request.ts      # Request configuration
│   └── navigation.ts   # Navigation API wrappers
├── proxy.ts            # Middleware (was middleware.ts in Next.js <16)
└── app/
    ├── layout.tsx      # Root layout (minimal wrapper)
    └── [locale]/
        ├── layout.tsx  # Locale-specific layout with NextIntlClientProvider
        ├── page.tsx    # Locale-specific homepage
        └── not-found.tsx
messages/
├── en.json
└── id.json
```

## Setup Steps

### 1. Install next-intl

```bash
npm install next-intl
```

### 2. Configure next.config.ts

Update your `next.config.ts` to use the next-intl plugin:

```typescript
import type { NextConfig } from "next";
import createNextIntlPlugin from "next-intl/plugin";

const withNextIntl = createNextIntlPlugin();

const nextConfig: NextConfig = {
  reactCompiler: true,
};

export default withNextIntl(nextConfig);
```

### 3. Key Configuration Files

#### `src/i18n/routing.ts`

Central place for routing configuration:

```typescript
import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  // A list of all locales that are supported
  locales: ["en", "id"],

  // Used when no locale matches
  defaultLocale: "en",
});
```

#### `src/i18n/request.ts`

Request configuration that reads the locale:

```typescript
import { getRequestConfig } from "next-intl/server";
import { routing } from "./routing";

export default getRequestConfig(async ({ requestLocale }) => {
  // This typically corresponds to the `[locale]` segment
  let locale = await requestLocale;

  // Ensure that a valid locale is used
  if (!locale || !routing.locales.includes(locale as any)) {
    locale = routing.defaultLocale;
  }

  return {
    locale,
    messages: (await import(`../../messages/${locale}.json`)).default,
  };
});
```

#### `src/i18n/navigation.ts`

Navigation API wrappers:

```typescript
import { createNavigation } from "next-intl/navigation";
import { routing } from "./routing";

export const { Link, redirect, usePathname, useRouter, getPathname } =
  createNavigation(routing);
```

#### `src/proxy.ts` (was middleware.ts)

Handles locale negotiation and routing:

```typescript
import createMiddleware from "next-intl/middleware";
import { routing } from "./i18n/routing";

export default createMiddleware(routing);

export const config = {
  // Match all pathnames except for
  // - … if they start with `/api`, `/_next` or `/_vercel`
  // - … the ones containing a dot (e.g. `favicon.ico`)
  matcher: ["/((?!api|_next|_vercel|.*\\..*).*)"],
};
```

### 4. App Structure

#### `src/app/layout.tsx`

Minimal root layout (just passes children through):

```typescript
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
```

#### `src/app/page.tsx`

Root page that redirects to default locale:

```typescript
import { redirect } from "next/navigation";
import { routing } from "@/i18n/routing";

// This page only renders when the app is built statically (output: 'export')
export default function RootPage() {
  redirect(`/${routing.defaultLocale}`);
}
```

#### `src/app/[locale]/layout.tsx`

Locale-specific layout with NextIntlClientProvider:

```typescript
import { notFound } from "next/navigation";
import { NextIntlClientProvider } from "next-intl";
import { getMessages } from "next-intl/server";
import { setRequestLocale } from "next-intl/server";
import { routing } from "@/i18n/routing";
import Providers from "../providers";

type Props = {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
};

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export default async function LocaleLayout({ children, params }: Props) {
  const { locale } = await params;

  // Ensure that the incoming locale is valid
  if (!routing.locales.includes(locale as any)) {
    notFound();
  }

  // Enable static rendering
  setRequestLocale(locale);

  // Providing all messages to the client
  // side is the easiest way to get started
  const messages = await getMessages();

  return (
    <html lang={locale}>
      <body>
        <NextIntlClientProvider messages={messages}>
          <Providers>{children}</Providers>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

#### `src/app/[locale]/page.tsx`

Locale-specific page:

```typescript
import { setRequestLocale } from "next-intl/server";
import { getTranslations } from "next-intl/server";

type Props = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: Props) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "common" });

  return {
    title: t("welcome"),
  };
}

export default async function HomePage({ params }: Props) {
  const { locale } = await params;

  // Enable static rendering
  setRequestLocale(locale);

  const t = await getTranslations("common");

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold">{t("welcome")}</h1>
      <p className="text-gray-600">Current locale: {locale}</p>
    </div>
  );
}
```

## Usage

### In Server Components

```typescript
import { getTranslations } from "next-intl/server";

export default async function MyComponent() {
  const t = await getTranslations("namespace");

  return <h1>{t("key")}</h1>;
}
```

### In Client Components

```typescript
"use client";

import { useTranslations } from "next-intl";

export default function MyComponent() {
  const t = useTranslations("namespace");

  return <h1>{t("key")}</h1>;
}
```

### Navigation

Use the wrapped navigation components from `@/i18n/navigation`:

```typescript
import { Link, useRouter, usePathname } from "@/i18n/navigation";

// Link component
<Link href="/about">About</Link>

// Router
const router = useRouter();
router.push("/about");

// Pathname
const pathname = usePathname();
```

## Message Files

Messages are stored in JSON files under `messages/`:

```json
// messages/en.json
{
  "common": {
    "welcome": "Welcome"
  }
}

// messages/id.json
{
  "common": {
    "welcome": "Selamat Datang"
  }
}
```

## Key Differences from Next.js 15

1. **proxy.ts instead of middleware.ts**: In Next.js 16, the middleware file is now called `proxy.ts`
2. **Async params**: The `params` prop is now a Promise and must be awaited
3. **Plugin configuration**: The plugin is created without arguments and wraps the entire config

## Resources

- [Official Documentation](https://next-intl.dev/docs/getting-started/app-router)
- [Routing](https://next-intl.dev/docs/routing)
- [Middleware](https://next-intl.dev/docs/routing/middleware)
- [Examples](https://next-intl.dev/examples)

export const config = {
matcher: ['/((?!api|_next|_vercel|.*\\\\..*).*)'],
};

````

### 4. Layout Configuration

Your `app/[locale]/layout.tsx` should:

```typescript
import { notFound } from 'next/navigation';
import { NextIntlClientProvider, hasLocale } from 'next-intl';
import { getMessages } from 'next-intl/server';
import { setRequestLocale } from 'next-intl/server';
import { routing } from '@/i18n/routing';

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export default async function LocaleLayout({ children, params }) {
  const { locale } = await params;

  if (!hasLocale(routing.locales, locale)) {
    notFound();
  }

  // Enable static rendering
  setRequestLocale(locale);

  const messages = await getMessages();

  return (
    <html lang={locale}>
      <body>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
````

## Usage

### In Client Components

```typescript
'use client';
import { useTranslations } from 'next-intl';

export default function MyComponent() {
  const t = useTranslations('common');
  return <h1>{t('welcome')}</h1>;
}
```

### In Server Components

```typescript
import { getTranslations } from 'next-intl/server';

export default async function MyComponent() {
  const t = await getTranslations('common');
  return <h1>{t('welcome')}</h1>;
}
```

### Navigation

Always use the wrapped navigation APIs from `@/i18n/navigation`:

```typescript
'use client';
import { Link, useRouter } from '@/i18n/navigation';

export default function Navigation() {
  const router = useRouter();

  return (
    <nav>
      <Link href="/about">About</Link>
      <button onClick={() => router.push('/dashboard')}>
        Dashboard
      </button>
    </nav>
  );
}
```

## Important Notes

1. **Use navigation from `@/i18n/navigation`**, not from `next/navigation`
2. **Call `setRequestLocale(locale)`** in layouts and pages for static rendering
3. **Add `generateStaticParams()`** to enable static rendering
4. **In Next.js 16**, `params` is a Promise, so use `await params`
5. **File name changed**: `middleware.ts` → `proxy.ts` in Next.js 16

## References

- [next-intl Documentation](https://next-intl.dev/docs/getting-started/app-router)
- [Routing Setup](https://next-intl.dev/docs/routing/setup)
- [Next.js 16 Changes](https://nextjs.org/blog/next-16)
