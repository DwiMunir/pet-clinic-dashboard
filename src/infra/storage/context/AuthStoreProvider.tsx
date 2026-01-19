"use client";

import { createContext, useContext, useRef, ReactNode } from "react";
import { useStore } from "zustand";
import { useAuthStore } from "../zustand/auth_store";
import { AuthSlice } from "../zustand/slices/authSlice";

type AuthStoreApi = typeof useAuthStore;

const AuthStoreContext = createContext<AuthStoreApi | undefined>(undefined);

export interface AuthStoreProviderProps {
  children: ReactNode;
}

export const AuthStoreProvider = ({ children }: AuthStoreProviderProps) => {
  const storeRef = useRef<AuthStoreApi>(useAuthStore);
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
  selector: (store: AuthSlice) => T,
): T => {
  const authStoreContext = useContext(AuthStoreContext);

  if (!authStoreContext) {
    throw new Error(
      "useAuthStoreContext must be used within AuthStoreProvider",
    );
  }

  return useStore(authStoreContext, selector);
};
