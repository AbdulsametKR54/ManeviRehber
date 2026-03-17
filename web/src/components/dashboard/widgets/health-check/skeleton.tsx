import React from "react";

export function HealthCheckSkeleton() {
  return (
    <div className="space-y-6 animate-pulse">
      <div className="flex justify-between items-center">
        <div className="h-5 w-32 bg-muted rounded-md" />
        <div className="h-6 w-16 bg-muted rounded-full" />
      </div>
      <div className="space-y-4">
        <div className="h-4 w-full bg-muted/60 rounded-md" />
        <div className="h-4 w-5/6 bg-muted/60 rounded-md" />
        <div className="h-4 w-4/6 bg-muted/60 rounded-md" />
      </div>
    </div>
  );
}
