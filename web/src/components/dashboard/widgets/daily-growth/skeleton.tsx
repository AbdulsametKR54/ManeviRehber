import React from "react";

export function DailyGrowthSkeleton() {
  return (
    <div className="space-y-4 animate-pulse">
      <div className="h-4 w-32 bg-muted rounded-md" />
      <div className="space-y-2">
        <div className="h-10 w-24 bg-muted rounded-md" />
        <div className="h-4 w-20 bg-muted rounded-md" />
      </div>
      <div className="h-2 w-full bg-muted rounded-full" />
      <div className="h-3 w-40 bg-muted/60 rounded-md" />
    </div>
  );
}
