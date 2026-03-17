import React from "react";

export function SpecialDaysCountdownSkeleton() {
  return (
    <div className="space-y-6 animate-pulse">
      <div className="h-5 w-40 bg-muted rounded-md" />
      <div className="space-y-4 divide-y divide-border/50">
        {[1, 2, 3].map((i) => (
          <div key={i} className="flex justify-between items-center pt-4 first:pt-0">
            <div className="space-y-2">
              <div className="h-4 w-32 bg-muted rounded-md" />
              <div className="h-3 w-20 bg-muted/60 rounded-md" />
            </div>
            <div className="h-8 w-16 bg-muted rounded-lg" />
          </div>
        ))}
      </div>
    </div>
  );
}
