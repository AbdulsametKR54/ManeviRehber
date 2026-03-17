"use client";

import { Suspense } from "react";
import { LoadingBar } from "@/components/ui/loading-bar";

export function RouteLoaderProvider({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Suspense fallback={null}>
        <LoadingBar />
      </Suspense>
      {children}
    </>
  );
}
