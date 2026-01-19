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
