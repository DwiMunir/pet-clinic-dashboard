# Usage Guide - Next.js 16 Design Pattern

## Quick Reference

### 1. Creating a New API Service

**File: `src/infra/services/api/userService.ts`**
```typescript
import { axiosClient } from "@infra/axios";
import { User } from "@types-app/auth";

export const getUsers = async () => {
  const response = await axiosClient.get<User[]>("/users");
  return response.data;
};

export const getUserById = async (id: string) => {
  const response = await axiosClient.get<User>(`/users/${id}`);
  return response.data;
};
```

### 2. Creating React Query Hooks

**File: `src/infra/queries/hooks/user.ts`**
```typescript
import { useQuery, useMutation } from "@tanstack/react-query";
import { QueryKey } from "../queryKey";
import * as userService from "@infra/services/api/userService";

export const useQueryGetUsers = () =>
  useQuery({
    queryKey: [QueryKey.GET_USERS],
    queryFn: userService.getUsers,
  });

export const useQueryGetUserById = (id: string) =>
  useQuery({
    queryKey: [QueryKey.GET_USER_BY_ID, id],
    queryFn: () => userService.getUserById(id),
    enabled: !!id,
  });
```

### 3. Creating a New Component

**File: `src/components/atoms/my-new-component/index.tsx`**
```typescript
export interface MyNewComponentProps {
  title: string;
  description?: string;
}

export const MyNewComponent = ({ title, description }: MyNewComponentProps) => {
  return (
    <div>
      <h2>{title}</h2>
      {description && <p>{description}</p>}
    </div>
  );
};
```

### 4. Creating a Zustand Slice

**File: `src/infra/storage/zustand/slices/userSlice.ts`**
```typescript
import { StateCreator } from "zustand";

export interface UserSlice {
  users: User[];
  setUsers: (users: User[]) => void;
}

export const createUserSlice: StateCreator<UserSlice> = (set) => ({
  users: [],
  setUsers: (users) => set({ users }),
});
```

### 5. Using Store in Components

```typescript
"use client";

import { useAuthStoreContext } from "@infra/storage/context/AuthStoreProvider";

export default function MyComponent() {
  const user = useAuthStoreContext((state) => state.user);
  const logout = useAuthStoreContext((state) => state.logout);

  return (
    <div>
      <p>Hello, {user?.name}</p>
      <button onClick={logout}>Logout</button>
    </div>
  );
}
```

### 6. Using next-intl Navigation APIs

**Use the wrapper APIs from `@/i18n/navigation` instead of Next.js directly:**

```typescript
"use client";

import { Link, useRouter, usePathname } from "@/i18n/navigation";

export default function Navigation() {
  const router = useRouter();
  const pathname = usePathname();

  return (
    <nav>
      <Link href="/about">About</Link>
      <button onClick={() => router.push("/dashboard")}>Dashboard</button>
      <p>Current path: {pathname}</p>
    </nav>
  );
}
```

### 7. Using Translations in Components

**Client Component:**
```typescript
"use client";

import { useTranslations } from "next-intl";

export default function MyClientComponent() {
  const t = useTranslations("common");
  return <h1>{t("welcome")}</h1>;
}
```

**Server Component:**
```typescript
import { getTranslations } from "next-intl/server";

export default async function MyServerComponent() {
  const t = await getTranslations("common");
  return <h1>{t("welcome")}</h1>;
}
```

## next-intl Configuration

### File Structure
```
src/
├── i18n/
│   ├── routing.ts      # Routing configuration
│   ├── navigation.ts   # Navigation APIs
│   └── request.ts      # Request configuration
├── proxy.ts           # Middleware (was middleware.ts in Next.js <16)
└── app/
    └── [locale]/
        ├── layout.tsx
        └── page.tsx
```

### Important Files

**1. `src/i18n/routing.ts` - Central routing configuration:**
```typescript
import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  locales: ["en", "id"],
  defaultLocale: "en",
});
```

**2. `src/proxy.ts` - Middleware for routing:**
```typescript
import createMiddleware from "next-intl/middleware";
import { routing } from "./i18n/routing";

export default createMiddleware(routing);
```

**3. `next.config.ts` - Plugin configuration:**
```typescript
import createNextIntlPlugin from "next-intl/plugin";

const withNextIntl = createNextIntlPlugin("./src/i18n/request.ts");

export default withNextIntl({
  // your Next.js config
});
```

## Folder Structure Conventions

- **atoms/**: Single-purpose UI components (buttons, inputs)
- **molecules/**: Combinations of atoms (forms, cards)
- **organisms/**: Complex UI sections (headers, sidebars)
- **page/**: Page-specific logic and components
- **hooks/**: Reusable custom hooks
- **infra/**: Infrastructure and external dependencies
- **types/**: TypeScript type definitions

## Next.js 16 Specific Features

### Async Request APIs
In Next.js 16, several APIs are now async:
- `headers()`, `cookies()`, `params`, `searchParams`

**Example:**
```typescript
// app/[locale]/page.tsx
export default async function Page({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  return <div>Locale: {locale}</div>;
}
```

### Client Components
Always use "use client" directive for:
- Components using hooks (useState, useEffect, etc.)
- Event handlers
- Browser APIs
- Zustand stores
- React Query hooks

### Migration from Next.js 15 to 16

**1. Update async params in pages:**
```typescript
// Before (Next.js 15)
export default function Page({ params }: { params: { id: string } }) {
  return <div>{params.id}</div>;
}

// After (Next.js 16)
export default async function Page({ 
  params 
}: { 
  params: Promise<{ id: string }> 
}) {
  const { id } = await params;
  return <div>{id}</div>;
}
```

**2. Update async request APIs:**
```typescript
// Before (Next.js 15)
import { headers } from "next/headers";
const headersList = headers();

// After (Next.js 16)
import { headers } from "next/headers";
const headersList = await headers();
```

**3. Update next-intl configuration:**
```typescript
// Use requestLocale instead of locale in i18n.ts
const locale = await requestLocale;
```

## Best Practices

1. **Keep components small and focused**
2. **Use TypeScript for type safety**
3. **Separate business logic from UI**
4. **Use custom hooks for reusable logic**
5. **Follow the folder structure**
6. **Write meaningful component names**
7. **Add JSDoc comments for complex logic**
8. **Use "use client" only when necessary** (Next.js 16 Server Components)

## Common Patterns

### API Call Pattern
```
Service (API) → React Query Hook → Component
```

### State Management Pattern
```
Zustand Slice → Store → Context Provider → Component
```

### Component Pattern
```
Atoms → Molecules → Organisms → Page
```

