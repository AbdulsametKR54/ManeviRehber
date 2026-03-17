"use client";

import { useEffect } from "react";
import { Button } from "@/components/ui/button";
import { AlertTriangle } from "lucide-react";

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Hatayı logla
    console.error("Global Application Error:", error);
  }, [error]);

  return (
    <div className="flex h-screen w-full flex-col items-center justify-center bg-background px-4 text-center">
      <div className="flex max-w-md flex-col items-center gap-6 rounded-2xl border border-border bg-card p-10 shadow-lg">
        <div className="rounded-full bg-red-100 p-4 dark:bg-red-900/20">
          <AlertTriangle className="h-10 w-10 text-red-600 dark:text-red-400" />
        </div>
        <div className="space-y-2">
          <h1 className="text-2xl font-bold tracking-tight text-foreground">
            Beklenmeyen Bir Hata Oluştu
          </h1>
          <p className="text-sm text-muted-foreground">
            İsteğinizi gerçekleştirirken sistemsel bir sorunla karşılaştık. Lütfen tekrar deneyin.
          </p>
        </div>
        <Button 
            onClick={() => reset()} 
            size="lg" 
            className="w-full bg-primary hover:bg-primary/90 text-white font-semibold rounded-xl"
        >
          Yeniden Dene
        </Button>
      </div>
    </div>
  );
}
