"use client";

import React from "react";
import useSWR from "swr";
import { fetcher } from "@/lib/fetcher";
import { useDashboardWidgetsStore } from "@/store/dashboard-widgets";
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer 
} from "recharts";
import { format, parseISO } from "date-fns";
import { tr } from "date-fns/locale";
import { WeeklyContentActivitySkeleton } from "./skeleton";

interface WeeklyActivityData {
  dates: string[];
  counts: number[];
}

const WeeklyContentActivityWidget = () => {
  const { autoRefresh, autoRefreshInterval } = useDashboardWidgetsStore();
  const isRefreshing = autoRefresh["weeklyContentActivity"] ?? false;
  const interval = autoRefreshInterval["weeklyContentActivity"] ?? 60000;

  const { data, error, isLoading } = useSWR<WeeklyActivityData>(
    "/dashboard/weekly-content-activity", 
    (url: string) => fetcher<WeeklyActivityData>(url),
    {
      refreshInterval: isRefreshing ? interval : 0
    }
  );

  if (isLoading) return <WeeklyContentActivitySkeleton />;
  if (error) return <div className="text-sm text-red-500 font-medium">Veri alınamadı</div>;
  if (!data) return <div className="text-sm text-muted-foreground italic flex items-center h-full">Henüz aktivite verisi yok</div>;

  const chartData = data.dates.map((date, index) => ({
    date: format(parseISO(date), "dd MMM", { locale: tr }),
    count: data.counts[index],
  }));

  return (
    <div className="flex flex-col gap-4 h-full">
      <h2 className="text-lg font-semibold text-slate-700 dark:text-slate-200 uppercase tracking-tight">
        Haftalık İçerik Aktivitesi
      </h2>
      
      <div className="h-48 w-full mt-2">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={chartData} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" opacity={0.5} />
            <XAxis 
              dataKey="date" 
              axisLine={false} 
              tickLine={false} 
              tick={{ fontSize: 10, fill: "#94A3B8" }} 
              dy={10}
            />
            <YAxis 
              axisLine={false} 
              tickLine={false} 
              tick={{ fontSize: 10, fill: "#94A3B8" }} 
            />
            <Tooltip 
              contentStyle={{ 
                borderRadius: "8px", 
                border: "none", 
                boxShadow: "0 10px 15px -3px rgb(0 0 0 / 0.1)",
                fontSize: "12px",
                fontWeight: "bold"
              }}
              cursor={{ stroke: "#3b82f6", strokeWidth: 2, strokeDasharray: "5 5" }}
            />
            <Line 
              type="monotone" 
              dataKey="count" 
              stroke="#3b82f6" 
              strokeWidth={3} 
              dot={{ r: 4, fill: "#3b82f6", strokeWidth: 2, stroke: "#fff" }}
              activeDot={{ r: 6, strokeWidth: 0 }}
              animationDuration={1500}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>

      <p className="text-xs text-muted-foreground italic mt-auto">
        Son 7 günün içerik ekleme grafiği
      </p>
    </div>
  );
};

export default WeeklyContentActivityWidget;
