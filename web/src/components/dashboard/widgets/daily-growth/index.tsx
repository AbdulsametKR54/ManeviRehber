"use client";

import React from "react";
import useSWR from "swr";
import { fetcher } from "@/lib/fetcher";
import { useDashboardWidgetsStore } from "@/store/dashboard-widgets";
import { ArrowUp, ArrowDown, MoveRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { DailyGrowthSkeleton } from "./skeleton";

interface DailyGrowthData {
  todayCount: number;
  yesterdayCount: number;
  difference: number;
  trend: "up" | "down" | "equal";
}

const DailyGrowthWidget = () => {
  const { autoRefresh, autoRefreshInterval } = useDashboardWidgetsStore();
  const isRefreshing = autoRefresh["dailyGrowth"] ?? false;
  const interval = autoRefreshInterval["dailyGrowth"] ?? 60000;

  const { data, error, isLoading } = useSWR<DailyGrowthData>(
    "/dashboard/daily-growth", 
    (url: string) => fetcher<DailyGrowthData>(url),
    {
      refreshInterval: isRefreshing ? interval : 0
    }
  );

  if (isLoading) return <DailyGrowthSkeleton />;
  if (error) return <div className="text-sm text-red-500">Veri alınamadı</div>;
  if (!data) return <div className="text-sm text-muted-foreground italic flex items-center h-full">Gösterilecek veri bulunamadı</div>;

  const getTrendConfig = (trend: string) => {
    switch (trend) {
      case "up":
        return {
          icon: <ArrowUp className="w-4 h-4" />,
          color: "text-green-500 shadow-green-500/20",
          bgColor: "bg-green-500/10",
          text: `Düne göre +${data.difference}`
        };
      case "down":
        return {
          icon: <ArrowDown className="w-4 h-4" />,
          color: "text-red-500 shadow-red-500/20",
          bgColor: "bg-red-500/10",
          text: `Düne göre ${data.difference}`
        };
      default:
        return {
          icon: <MoveRight className="w-4 h-4" />,
          color: "text-gray-500 shadow-gray-500/20",
          bgColor: "bg-gray-500/10",
          text: "Düne göre aynı"
        };
    }
  };

  const trendConfig = getTrendConfig(data.trend);

  return (
    <div className="flex flex-col gap-4">
      <h2 className="text-lg font-semibold text-slate-700 dark:text-slate-200">Günlük İçerik Artışı</h2>
      
      <div className="flex flex-col gap-1">
        <div className="flex items-baseline gap-2">
            <span className="text-4xl font-black text-slate-800 dark:text-white">
                {data.todayCount}
            </span>
            <span className="text-sm font-medium text-muted-foreground">içerik</span>
        </div>

        <div className={cn(
            "flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold w-fit mt-1",
            trendConfig.bgColor,
            trendConfig.color
        )}>
            {trendConfig.icon}
            {trendConfig.text}
        </div>
      </div>

      <div className="mt-2 space-y-2">
        <div className="h-2 w-full bg-muted rounded-full overflow-hidden">
            <div 
                className={cn(
                    "h-full transition-all duration-500 rounded-full",
                    data.trend === "up" ? "bg-green-500" : data.trend === "down" ? "bg-red-500" : "bg-slate-400"
                )}
                style={{ width: `${Math.min(100, Math.max(5, (data.todayCount / (data.yesterdayCount || 10)) * 100))}%` }} 
            />
        </div>
        <p className="text-xs text-muted-foreground italic">
            Dün: <span className="font-medium text-foreground">{data.yesterdayCount}</span> içerik eklendi
        </p>
      </div>
    </div>
  );
};

export default DailyGrowthWidget;
