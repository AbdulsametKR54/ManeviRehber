"use client";

import React from "react";
import useSWR from "swr";
import { fetcher } from "@/lib/fetcher";
import { useDashboardWidgetsStore } from "@/store/dashboard-widgets";
import { format, parseISO } from "date-fns";
import { tr } from "date-fns/locale";
import { cn } from "@/lib/utils";
import { SpecialDaysCountdownSkeleton } from "./skeleton";

interface SpecialDayItem {
  name: string;
  date: string;
  daysLeft: number;
}

const SpecialDaysCountdownWidget = () => {
  const { autoRefresh, autoRefreshInterval } = useDashboardWidgetsStore();
  const isRefreshing = autoRefresh["specialDaysCountdown"] ?? false;
  const interval = autoRefreshInterval["specialDaysCountdown"] ?? 60000;

  const { data, error, isLoading } = useSWR<SpecialDayItem[]>(
    "/dashboard/special-days-countdown", 
    (url: string) => fetcher<SpecialDayItem[]>(url),
    {
      refreshInterval: isRefreshing ? interval : 0
    }
  );

  if (isLoading) return <SpecialDaysCountdownSkeleton />;
  if (error) return <div className="text-sm text-red-500 font-medium font-medium">Veri alınamadı</div>;
  if (!data || data.length === 0) return <div className="text-sm text-muted-foreground italic flex items-center h-full">Yaklaşan özel gün bulunmuyor</div>;

  const getDaysColor = (days: number) => {
    if (days <= 3) return "text-red-600 bg-red-500/10 border-red-500/20";
    if (days <= 10) return "text-yellow-600 bg-yellow-500/10 border-yellow-500/20";
    return "text-blue-600 bg-blue-500/10 border-blue-500/20";
  };

  return (
    <div className="flex flex-col gap-6 h-full">
      <h2 className="text-lg font-semibold text-slate-700 dark:text-slate-200 uppercase tracking-tight">
        Yaklaşan Özel Günler
      </h2>

      <div className="flex flex-col divide-y divide-neutral-200/50 dark:divide-neutral-800/50">
        {data.map((item, index) => (
          <div key={index} className="py-3.5 flex items-center justify-between first:pt-0 last:pb-0 group transition-all">
            <div className="flex flex-col gap-1 overflow-hidden">
              <span className="text-sm font-bold text-slate-800 dark:text-slate-100 truncate group-hover:text-blue-600 transition-colors">
                {item.name}
              </span>
              <span className="text-[11px] text-muted-foreground font-medium">
                {format(parseISO(item.date), "dd MMMM yyyy", { locale: tr })}
              </span>
            </div>
            
            <div className={cn(
                "px-3 py-1.5 rounded-xl text-xs font-black border tracking-tight shrink-0",
                getDaysColor(item.daysLeft)
            )}>
              {item.daysLeft} gün
            </div>
          </div>
        ))}
      </div>

      <p className="text-[10px] text-muted-foreground italic mt-auto leading-tight">
        Dini ve milli özel günler otomatik olarak hesaplanmaktadır.
      </p>
    </div>
  );
};

export default SpecialDaysCountdownWidget;
