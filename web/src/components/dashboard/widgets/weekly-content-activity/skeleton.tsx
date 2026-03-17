import React from "react";

export function WeeklyContentActivitySkeleton() {
  return (
    <div className="space-y-4 animate-pulse">
      <div className="h-5 w-48 bg-muted rounded-md" />
      <div className="h-48 w-full bg-muted/40 rounded-xl" />
      <div className="h-3 w-40 bg-muted/60 rounded-md" />
    </div>
  );
}
