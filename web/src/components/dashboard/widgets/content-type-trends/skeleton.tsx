import React from "react";

export function ContentTypeTrendsSkeleton() {
  return (
    <div className="space-y-6 animate-pulse">
      <div className="h-5 w-48 bg-muted rounded-md" />
      <div className="h-56 w-full bg-muted/40 rounded-xl" />
      <div className="h-3 w-52 bg-muted/60 rounded-md" />
    </div>
  );
}
