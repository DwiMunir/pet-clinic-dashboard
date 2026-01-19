#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}   Populating Template Files                   ${NC}"
echo -e "${BLUE}   Next.js 16 Design Pattern                   ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if we're in a Next.js project
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json not found!${NC}"
    echo -e "${RED}Please run this script in your Next.js project root directory.${NC}"
    exit 1
fi

# Check if folder structure exists
if [ ! -d "src" ]; then
    echo -e "${RED}Error: src folder not found!${NC}"
    echo -e "${RED}Please run setup.sh first to create the folder structure.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Detected Next.js project with design pattern structure"
echo ""

# ==================== INFRASTRUCTURE FILES ====================

echo -e "${YELLOW}Creating infrastructure files...${NC}"

# Axios Client
echo -e "  Creating axios client..."
cat > src/infra/axios/axiosClient.ts << 'EOL'
import axios from "axios";
import { setupInterceptors } from "./interceptor";

const baseURL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3001/api";

export const axiosClient = axios.create({
  baseURL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 30000,
});

setupInterceptors(axiosClient);
EOL

# Axios Interceptor
cat > src/infra/axios/interceptor.ts << 'EOL'
import { AxiosInstance, AxiosError, InternalAxiosRequestConfig } from "axios";
import { ErrorResponse, handleApiError } from "./error";

export const setupInterceptors = (axiosInstance: AxiosInstance) => {
  // Request interceptor
  axiosInstance.interceptors.request.use(
    (config: InternalAxiosRequestConfig) => {
      // Add auth token if available
      if (typeof window !== "undefined") {
        const token = localStorage.getItem("authToken");
        if (token && config.headers) {
          config.headers.Authorization = `Bearer ${token}`;
        }
      }
      return config;
    },
    (error: AxiosError) => {
      return Promise.reject(error);
    }
  );

  // Response interceptor
  axiosInstance.interceptors.response.use(
    (response) => response,
    (error: AxiosError<ErrorResponse>) => {
      handleApiError(error);
      return Promise.reject(error);
    }
  );
};
EOL

# Axios Error Handler
cat > src/infra/axios/error.ts << 'EOL'
import { AxiosError } from "axios";

export interface ErrorResponse {
  message: string;
  statusCode?: number;
  errors?: Record<string, string[]>;
}

export const handleApiError = (error: AxiosError<ErrorResponse>) => {
  if (error.response) {
    // Server responded with error
    const { status, data } = error.response;
    
    switch (status) {
      case 401:
        console.error("Unauthorized - Please login again");
        // Redirect to login or refresh token
        if (typeof window !== "undefined") {
          localStorage.removeItem("authToken");
          window.location.href = "/auth/login";
        }
        break;
      case 403:
        console.error("Forbidden - You don't have permission");
        break;
      case 404:
        console.error("Not Found - Resource not found");
        break;
      case 500:
        console.error("Server Error - Please try again later");
        break;
      default:
        console.error(data?.message || "An error occurred");
    }
  } else if (error.request) {
    // Request made but no response
    console.error("Network Error - Please check your connection");
  } else {
    // Something else happened
    console.error("Error:", error.message);
  }
};
EOL

# Axios Index
cat > src/infra/axios/index.ts << 'EOL'
export { axiosClient } from "./axiosClient";
export { handleApiError } from "./error";
export type { ErrorResponse } from "./error";
EOL

# React Query Client
cat > src/infra/queries/queryClient.ts << 'EOL'
import { QueryClient } from "@tanstack/react-query";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      staleTime: 5 * 60 * 1000, // 5 minutes
    },
  },
});
EOL

# Query Keys
cat > src/infra/queries/queryKey.ts << 'EOL'
export enum QueryKey {
  // Auth
  GET_ME = "GET_ME",
  
  // Users
  GET_USERS = "GET_USERS",
  GET_USER_BY_ID = "GET_USER_BY_ID",
  
  // Add more query keys here
}
EOL

# Query Types
cat > src/infra/queries/type.ts << 'EOL'
export interface PaginationParams {
  page?: number;
  limit?: number;
  search?: string;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
EOL

# Query Hooks Index
cat > src/infra/queries/hooks/index.ts << 'EOL'
export * from "./auth";
EOL

# Auth Query Hook
cat > src/infra/queries/hooks/auth.ts << 'EOL'
import { useQuery, useMutation } from "@tanstack/react-query";
import { QueryKey } from "../queryKey";
import * as authService from "@infra/services/api/authService";
import { LoginRequest, RegisterRequest } from "@types-app/auth";

export const useQueryGetMe = () =>
  useQuery({
    queryKey: [QueryKey.GET_ME],
    queryFn: authService.getMe,
  });

export const useMutationLogin = () =>
  useMutation({
    mutationFn: (data: LoginRequest) => authService.login(data),
  });

export const useMutationRegister = () =>
  useMutation({
    mutationFn: (data: RegisterRequest) => authService.register(data),
  });
EOL

# Query Index
cat > src/infra/queries/index.ts << 'EOL'
export { queryClient } from "./queryClient";
export { QueryKey } from "./queryKey";
export * from "./hooks";
export type * from "./type";
EOL

# Auth Service
cat > src/infra/services/api/authService.ts << 'EOL'
import { axiosClient } from "@infra/axios";
import { LoginRequest, LoginResponse, RegisterRequest, User } from "@types-app/auth";

export const login = async (data: LoginRequest): Promise<LoginResponse> => {
  const response = await axiosClient.post<LoginResponse>("/auth/login", data);
  return response.data;
};

export const register = async (data: RegisterRequest): Promise<LoginResponse> => {
  const response = await axiosClient.post<LoginResponse>("/auth/register", data);
  return response.data;
};

export const getMe = async (): Promise<User> => {
  const response = await axiosClient.get<User>("/auth/me");
  return response.data;
};

export const logout = async (): Promise<void> => {
  await axiosClient.post("/auth/logout");
};
EOL

# Services Index
cat > src/infra/services/api/index.ts << 'EOL'
export * as authService from "./authService";
EOL

# Config Index
cat > src/infra/config/index.ts << 'EOL'
export const config = {
  apiBaseUrl: process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:3001/api",
  encryptionKey: process.env.NEXT_PUBLIC_ENCRYPTION_KEY || "",
  isDevelopment: process.env.NODE_ENV === "development",
  isProduction: process.env.NODE_ENV === "production",
};
EOL

# Auth Slice (Zustand)
cat > src/infra/storage/zustand/slices/authSlice.ts << 'EOL'
import { StateCreator } from "zustand";
import { User } from "@types-app/auth";

export interface AuthSlice {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  logout: () => void;
}

export const createAuthSlice: StateCreator<AuthSlice> = (set) => ({
  user: null,
  token: null,
  isAuthenticated: false,
  setUser: (user) => set({ user, isAuthenticated: !!user }),
  setToken: (token) => {
    if (token) {
      localStorage.setItem("authToken", token);
    } else {
      localStorage.removeItem("authToken");
    }
    set({ token });
  },
  logout: () => {
    localStorage.removeItem("authToken");
    set({ user: null, token: null, isAuthenticated: false });
  },
});
EOL

# Auth Store
cat > src/infra/storage/zustand/auth_store.ts << 'EOL'
import { create } from "zustand";
import { AuthSlice, createAuthSlice } from "./slices/authSlice";

export const useAuthStore = create<AuthSlice>()((...a) => ({
  ...createAuthSlice(...a),
}));
EOL

# Auth Store Provider
cat > src/infra/storage/context/AuthStoreProvider.tsx << 'EOL'
"use client";

import { createContext, useContext, useRef, ReactNode } from "react";
import { useStore } from "zustand";
import { useAuthStore } from "../zustand/auth_store";
import { AuthSlice } from "../zustand/slices/authSlice";

type AuthStoreApi = ReturnType<typeof useAuthStore>;

const AuthStoreContext = createContext<AuthStoreApi | undefined>(undefined);

export interface AuthStoreProviderProps {
  children: ReactNode;
}

export const AuthStoreProvider = ({ children }: AuthStoreProviderProps) => {
  const storeRef = useRef<AuthStoreApi>();
  if (!storeRef.current) {
    storeRef.current = useAuthStore;
  }

  return (
    <AuthStoreContext.Provider value={storeRef.current}>
      {children}
    </AuthStoreContext.Provider>
  );
};

export const useAuthStoreContext = <T,>(
  selector: (store: AuthSlice) => T
): T => {
  const authStoreContext = useContext(AuthStoreContext);

  if (!authStoreContext) {
    throw new Error("useAuthStoreContext must be used within AuthStoreProvider");
  }

  return useStore(authStoreContext, selector);
};
EOL

echo -e "${GREEN}✓${NC} Infrastructure files created"

# ==================== TYPES ====================

echo -e "${YELLOW}Creating type definitions...${NC}"

cat > src/types/common.ts << 'EOL'
export interface BaseResponse<T = unknown> {
  data: T;
  message: string;
  success: boolean;
}

export interface ErrorDetail {
  field: string;
  message: string;
}
EOL

cat > src/types/auth.ts << 'EOL'
export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  role: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  name: string;
}

export interface LoginResponse {
  user: User;
  token: string;
}
EOL

cat > src/types/api.ts << 'EOL'
export interface ApiError {
  message: string;
  statusCode: number;
  errors?: Record<string, string[]>;
}

export interface ApiResponse<T> {
  data: T;
  message: string;
}
EOL

echo -e "${GREEN}✓${NC} Type definitions created"

# ==================== HOOKS ====================

echo -e "${YELLOW}Creating custom hooks...${NC}"

cat > src/hooks/useDebounce.ts << 'EOL'
import { useState, useEffect } from "react";

export function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}
EOL

cat > src/hooks/useClickOutside.tsx << 'EOL'
import { useEffect, RefObject } from "react";

export function useClickOutside<T extends HTMLElement = HTMLElement>(
  ref: RefObject<T>,
  handler: (event: MouseEvent | TouchEvent) => void
) {
  useEffect(() => {
    const listener = (event: MouseEvent | TouchEvent) => {
      const el = ref?.current;
      if (!el || el.contains(event.target as Node)) {
        return;
      }
      handler(event);
    };

    document.addEventListener("mousedown", listener);
    document.addEventListener("touchstart", listener);

    return () => {
      document.removeEventListener("mousedown", listener);
      document.removeEventListener("touchstart", listener);
    };
  }, [ref, handler]);
}
EOL

echo -e "${GREEN}✓${NC} Custom hooks created"

# ==================== COMPONENTS ====================

echo -e "${YELLOW}Creating component templates...${NC}"

# Button Component
cat > src/components/atoms/my-button/index.tsx << 'EOL'
import React from "react";

export interface MyButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "danger" | "ghost";
  size?: "sm" | "md" | "lg";
  isLoading?: boolean;
}

export const MyButton = ({
  children,
  variant = "primary",
  size = "md",
  isLoading = false,
  className = "",
  disabled,
  ...props
}: MyButtonProps) => {
  const baseStyles = "font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2";
  
  const variantStyles = {
    primary: "bg-blue-600 hover:bg-blue-700 text-white focus:ring-blue-500",
    secondary: "bg-gray-200 hover:bg-gray-300 text-gray-900 focus:ring-gray-500",
    danger: "bg-red-600 hover:bg-red-700 text-white focus:ring-red-500",
    ghost: "hover:bg-gray-100 text-gray-700 focus:ring-gray-500",
  };

  const sizeStyles = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-4 py-2 text-base",
    lg: "px-6 py-3 text-lg",
  };

  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${className} ${
        (disabled || isLoading) ? "opacity-50 cursor-not-allowed" : ""
      }`}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <span className="flex items-center gap-2">
          <svg className="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Loading...
        </span>
      ) : (
        children
      )}
    </button>
  );
};
EOL

# Text Input Component
cat > src/components/atoms/my-text-input/index.tsx << 'EOL'
import React, { forwardRef } from "react";

export interface MyTextInputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  helperText?: string;
}

export const MyTextInput = forwardRef<HTMLInputElement, MyTextInputProps>(
  ({ label, error, helperText, className = "", ...props }, ref) => {
    return (
      <div className="w-full">
        {label && (
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {label}
          </label>
        )}
        <input
          ref={ref}
          className={`w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 ${
            error ? "border-red-500" : "border-gray-300"
          } ${className}`}
          {...props}
        />
        {error && <p className="mt-1 text-sm text-red-600">{error}</p>}
        {helperText && !error && (
          <p className="mt-1 text-sm text-gray-500">{helperText}</p>
        )}
      </div>
    );
  }
);

MyTextInput.displayName = "MyTextInput";
EOL

# Checkbox Component
cat > src/components/atoms/my-checkbox/index.tsx << 'EOL'
import React, { forwardRef } from "react";

export interface MyCheckboxProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const MyCheckbox = forwardRef<HTMLInputElement, MyCheckboxProps>(
  ({ label, error, className = "", ...props }, ref) => {
    return (
      <div className="flex items-start">
        <div className="flex items-center h-5">
          <input
            ref={ref}
            type="checkbox"
            className={`w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500 ${className}`}
            {...props}
          />
        </div>
        {label && (
          <div className="ml-3">
            <label className="text-sm text-gray-700">{label}</label>
            {error && <p className="text-sm text-red-600">{error}</p>}
          </div>
        )}
      </div>
    );
  }
);

MyCheckbox.displayName = "MyCheckbox";
EOL

# Atoms Index
cat > src/components/atoms/index.ts << 'EOL'
export * from "./my-button";
export * from "./my-text-input";
export * from "./my-checkbox";
EOL

# Modal Component
cat > src/components/molecules/my-modal/index.tsx << 'EOL'
"use client";

import React, { useRef } from "react";
import { useClickOutside } from "@hooks/useClickOutside";

export interface MyModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
  size?: "sm" | "md" | "lg" | "xl";
}

export const MyModal = ({
  isOpen,
  onClose,
  title,
  children,
  footer,
  size = "md",
}: MyModalProps) => {
  const modalRef = useRef<HTMLDivElement>(null);
  useClickOutside(modalRef, onClose);

  if (!isOpen) return null;

  const sizeStyles = {
    sm: "max-w-md",
    md: "max-w-lg",
    lg: "max-w-2xl",
    xl: "max-w-4xl",
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div
        ref={modalRef}
        className={`bg-white rounded-lg shadow-xl ${sizeStyles[size]} w-full mx-4`}
      >
        {/* Header */}
        {title && (
          <div className="flex items-center justify-between p-4 border-b">
            <h3 className="text-lg font-semibold">{title}</h3>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 transition-colors"
            >
              <svg
                className="w-6 h-6"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        )}

        {/* Body */}
        <div className="p-4">{children}</div>

        {/* Footer */}
        {footer && <div className="p-4 border-t bg-gray-50">{footer}</div>}
      </div>
    </div>
  );
};
EOL

# Molecules Index
cat > src/components/molecules/index.tsx << 'EOL'
export * from "./my-modal";
EOL

echo -e "${GREEN}✓${NC} Component templates created"

# ==================== APP FILES ====================

echo -e "${YELLOW}Creating app files...${NC}"

# Providers
cat > src/app/providers.tsx << 'EOL'
"use client";

import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "@infra/queries";
import { AuthStoreProvider } from "@infra/storage/context/AuthStoreProvider";

export default function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthStoreProvider>
        {children}
      </AuthStoreProvider>
    </QueryClientProvider>
  );
}
EOL

# Dashboard Page Component
cat > src/page/dashboard/index.tsx << 'EOL'
"use client";

import { useAuthStoreContext } from "@infra/storage/context/AuthStoreProvider";

export default function Dashboard() {
  const user = useAuthStoreContext((state) => state.user);

  return (
    <div className="container mx-auto p-8">
      <h1 className="text-3xl font-bold mb-4">Dashboard</h1>
      <p className="text-gray-600">
        Welcome back, {user?.name || "User"}!
      </p>
    </div>
  );
}
EOL

# i18n Routing Configuration
cat > src/i18n/routing.ts << 'EOL'
import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  // A list of all locales that are supported
  locales: ["en", "id"],

  // Used when no locale matches
  defaultLocale: "en",
});
EOL

# i18n Navigation
cat > src/i18n/navigation.ts << 'EOL'
import { createNavigation } from "next-intl/navigation";
import { routing } from "./routing";

// Lightweight wrappers around Next.js' navigation
// APIs that consider the routing configuration
export const { Link, redirect, usePathname, useRouter, getPathname } =
  createNavigation(routing);
EOL

# Example Layout with i18n (Next.js 16)
cat > src/app/\[locale\]/layout.example.tsx << 'EOL'
import { notFound } from "next/navigation";
import { NextIntlClientProvider, hasLocale } from "next-intl";
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
  // Next.js 16: params is now a Promise
  const { locale } = await params;

  // Ensure that the incoming locale is valid
  if (!hasLocale(routing.locales, locale)) {
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
EOL

# Example Page with async params (Next.js 16)
cat > src/app/\[locale\]/page.example.tsx << 'EOL'
import { setRequestLocale } from "next-intl/server";
import { useTranslations, getTranslations } from "next-intl";

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
  // Next.js 16: params is now a Promise
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
EOL

# Note: i18n.config.ts is replaced by i18n/routing.ts in the new structure
# Keeping this for backward compatibility if needed
cat > src/i18n.config.ts << 'EOL'
// This file is kept for backward compatibility
// The routing configuration is now in src/i18n/routing.ts
import { routing } from "./i18n/routing";

export const locales = routing.locales;
export type Locale = (typeof locales)[number];
export const defaultLocale = routing.defaultLocale;
EOL

# i18n Request Configuration
cat > src/i18n/request.ts << 'EOL'
import { getRequestConfig } from "next-intl/server";
import { hasLocale } from "next-intl";
import { routing } from "./routing";

export default getRequestConfig(async ({ requestLocale }) => {
  // This typically corresponds to the `[locale]` segment
  const requested = await requestLocale;
  const locale = hasLocale(routing.locales, requested)
    ? requested
    : routing.defaultLocale;

  return {
    locale,
    messages: (await import(`../../messages/${locale}.json`)).default,
  };
});
EOL

echo -e "${GREEN}✓${NC} App files created"

# ==================== PROXY (MIDDLEWARE) ====================

echo -e "${YELLOW}Creating proxy (middleware) for i18n...${NC}"

cat > src/proxy.ts << 'EOL'
import createMiddleware from "next-intl/middleware";
import { routing } from "./i18n/routing";

export default createMiddleware(routing);

export const config = {
  // Match all pathnames except for
  // - … if they start with `/api`, `/_next` or `/_vercel`
  // - … the ones containing a dot (e.g. `favicon.ico`)
  matcher: ["/((?!api|_next|_vercel|.*\\..*).*)"],
};
EOL

echo -e "${GREEN}✓${NC} Proxy (middleware) created"
echo -e "${YELLOW}  Note: In Next.js 16, middleware.ts is now called proxy.ts${NC}"

# ==================== i18n MESSAGES ====================

echo -e "${YELLOW}Creating i18n message files...${NC}"

cat > messages/en.json << 'EOL'
{
  "common": {
    "welcome": "Welcome",
    "loading": "Loading...",
    "error": "An error occurred",
    "success": "Success",
    "cancel": "Cancel",
    "save": "Save",
    "delete": "Delete",
    "edit": "Edit",
    "search": "Search"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout",
    "register": "Register",
    "email": "Email",
    "password": "Password",
    "forgotPassword": "Forgot Password?",
    "dontHaveAccount": "Don't have an account?",
    "alreadyHaveAccount": "Already have an account?"
  }
}
EOL

cat > messages/id.json << 'EOL'
{
  "common": {
    "welcome": "Selamat Datang",
    "loading": "Memuat...",
    "error": "Terjadi kesalahan",
    "success": "Berhasil",
    "cancel": "Batal",
    "save": "Simpan",
    "delete": "Hapus",
    "edit": "Ubah",
    "search": "Cari"
  },
  "auth": {
    "login": "Masuk",
    "logout": "Keluar",
    "register": "Daftar",
    "email": "Email",
    "password": "Kata Sandi",
    "forgotPassword": "Lupa Kata Sandi?",
    "dontHaveAccount": "Belum punya akun?",
    "alreadyHaveAccount": "Sudah punya akun?"
  }
}
EOL

echo -e "${GREEN}✓${NC} i18n message files created"

# ==================== DOCUMENTATION ====================

echo -e "${YELLOW}Creating documentation...${NC}"

cat > USAGE_GUIDE.md << 'EOL'
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

EOL

echo -e "${GREEN}✓${NC} Documentation created"

# Create next-intl specific documentation
cat > NEXTINTL_SETUP.md << 'EOL'
# next-intl Setup Guide

This project uses `next-intl` for internationalization based on the official documentation.

## File Structure

```
src/
├── i18n/
│   ├── routing.ts      # Central routing configuration
│   ├── navigation.ts   # Navigation API wrappers
│   └── request.ts      # Request configuration
├── proxy.ts            # Middleware (was middleware.ts in Next.js <16)
└── app/
    └── [locale]/
        ├── layout.tsx
        └── page.tsx
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
import createNextIntlPlugin from 'next-intl/plugin';

// Point to your request configuration
const withNextIntl = createNextIntlPlugin('./src/i18n/request.ts');

export default withNextIntl({
  // Your Next.js config
});
```

### 3. Key Configuration Files

#### `src/i18n/routing.ts`
Central place for routing configuration:

```typescript
import { defineRouting } from 'next-intl/routing';

export const routing = defineRouting({
  locales: ['en', 'id'],
  defaultLocale: 'en',
});
```

#### `src/i18n/request.ts`
Request configuration that reads the locale:

```typescript
import { getRequestConfig } from 'next-intl/server';
import { hasLocale } from 'next-intl';
import { routing } from './routing';

export default getRequestConfig(async ({ requestLocale }) => {
  const requested = await requestLocale;
  const locale = hasLocale(routing.locales, requested)
    ? requested
    : routing.defaultLocale;

  return {
    locale,
    messages: (await import(`../../messages/${locale}.json`)).default,
  };
});
```

#### `src/i18n/navigation.ts`
Navigation API wrappers:

```typescript
import { createNavigation } from 'next-intl/navigation';
import { routing } from './routing';

export const { Link, redirect, usePathname, useRouter, getPathname } =
  createNavigation(routing);
```

#### `src/proxy.ts` (was middleware.ts)
Handles locale negotiation and routing:

```typescript
import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

export default createMiddleware(routing);

export const config = {
  matcher: ['/((?!api|_next|_vercel|.*\\\\..*).*)'],
};
```

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
```

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

EOL

# ==================== SUMMARY ====================

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   Template Population Complete! 🎉            ${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}Files created:${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} Infrastructure files (axios, queries, services, storage)"
echo -e "  ${GREEN}✓${NC} Type definitions (auth, api, common)"
echo -e "  ${GREEN}✓${NC} Custom hooks (useDebounce, useClickOutside)"
echo -e "  ${GREEN}✓${NC} Component templates (Button, Input, Checkbox, Modal)"
echo -e "  ${GREEN}✓${NC} App configuration (providers)"
echo -e "  ${GREEN}✓${NC} next-intl configuration (routing, navigation, request, proxy)"
echo -e "  ${GREEN}✓${NC} Example files for Next.js 16 (layout, page with async params)"
echo -e "  ${GREEN}✓${NC} i18n message files (English & Indonesian)"
echo -e "  ${GREEN}✓${NC} Usage guide documentation"
echo ""
echo -e "${YELLOW}⚠ Important next-intl Setup (follow these steps):${NC}"
echo -e "  ${BLUE}1.${NC} Update ${GREEN}next.config.ts${NC} to include next-intl plugin:"
echo -e "     ${YELLOW}import createNextIntlPlugin from 'next-intl/plugin';${NC}"
echo -e "     ${YELLOW}const withNextIntl = createNextIntlPlugin('./src/i18n/request.ts');${NC}"
echo -e "     ${YELLOW}export default withNextIntl({ /* your config */ });${NC}"
echo -e "  ${BLUE}2.${NC} In Next.js 16, ${GREEN}middleware.ts${NC} is now ${GREEN}proxy.ts${NC}"
echo -e "  ${BLUE}3.${NC} Use navigation APIs from ${GREEN}@/i18n/navigation${NC}, not from 'next/navigation'"
echo -e "  ${BLUE}4.${NC} Use ${GREEN}setRequestLocale(locale)${NC} in layouts and pages for static rendering"
echo ""
echo -e "${YELLOW}⚠ Important for Next.js 16:${NC}"
echo -e "  ${BLUE}•${NC} Review ${GREEN}layout.example.tsx${NC} and ${GREEN}page.example.tsx${NC} for async params pattern"
echo -e "  ${BLUE}•${NC} In Next.js 16, params and searchParams are now Promises"
echo -e "  ${BLUE}•${NC} headers(), cookies() are also async - use ${GREEN}await headers()${NC}"
echo -e "  ${BLUE}•${NC} Add ${GREEN}generateStaticParams()${NC} to enable static rendering"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  ${BLUE}1.${NC} Review and customize the created files"
echo -e "  ${BLUE}2.${NC} Update tsconfig.json path aliases (see setup.sh output)"
echo -e "  ${BLUE}3.${NC} Update ${GREEN}next.config.ts${NC} with next-intl plugin (see below)"
echo -e "  ${BLUE}4.${NC} Install recommended dependencies: ${GREEN}npm install zustand @tanstack/react-query axios react-hook-form @hookform/resolvers zod next-intl dayjs react-hot-toast daisyui${NC}"
echo -e "  ${BLUE}5.${NC} Update .env with your API configuration"
echo -e "  ${BLUE}6.${NC} Copy ${GREEN}layout.example.tsx${NC} to ${GREEN}app/[locale]/layout.tsx${NC} and customize"
echo -e "  ${BLUE}7.${NC} Start development: ${GREEN}npm run dev${NC}"
echo -e "  ${BLUE}8.${NC} Read ${GREEN}USAGE_GUIDE.md${NC} for implementation patterns"
echo ""
echo -e "${YELLOW}next.config.ts example:${NC}"
echo -e "${GREEN}import createNextIntlPlugin from 'next-intl/plugin';${NC}"
echo -e "${GREEN}const withNextIntl = createNextIntlPlugin('./src/i18n/request.ts');${NC}"
echo ""
echo -e "${GREEN}export default withNextIntl({${NC}"
echo -e "${GREEN}  // Your Next.js config here${NC}"
echo -e "${GREEN}});${NC}"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo -e "  - ${GREEN}USAGE_GUIDE.md${NC} - Quick reference and usage examples"
echo -e "  - ${GREEN}DESIGN_PATTERN.md${NC} - Full design pattern documentation"
echo -e "  - ${GREEN}NEXTINTL_SETUP.md${NC} - Complete next-intl setup guide"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"
echo ""
