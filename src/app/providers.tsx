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
