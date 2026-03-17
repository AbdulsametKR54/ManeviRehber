"use client";

import React from "react";
import useSWR from "swr";
import { fetcher } from "@/lib/fetcher";
import { useDashboardWidgetsStore } from "@/store/dashboard-widgets";
import { Activity, Clock, Server, AlertTriangle } from "lucide-react";
import { cn } from "@/lib/utils";
import { HealthCheckSkeleton } from "./skeleton";

interface HealthCheckData {
  uptimeHours: number;
  averageResponseTimeMs: number;
  errorCountLast24Hours: number;
  status: "OK" | "Warning" | "Critical";
}

const HealthCheckWidget = () => {
  const { autoRefresh, autoRefreshInterval } = useDashboardWidgetsStore();
  const isRefreshing = autoRefresh["healthCheck"] ?? false;
  const interval = autoRefreshInterval["healthCheck"] ?? 30000;

  const { data, error, isLoading } = useSWR<HealthCheckData>(
    "/dashboard/health", 
    (url: string) => fetcher<HealthCheckData>(url),
    {
      refreshInterval: isRefreshing ? interval : 0
    }
  );

  if (isLoading) return <HealthCheckSkeleton />;
  if (error) return <div className="text-sm text-red-500 font-medium">Veri alınamadı</div>;
  if (!data) return <div className="text-sm text-muted-foreground italic flex items-center h-full">Sistem durumu kontrol edilemiyor</div>;

  const getStatusColor = (status: string) => {
    switch (status) {
      case "OK":
        return "bg-green-500/10 text-green-600 border-green-500/20";
      case "Warning":
        return "bg-yellow-500/10 text-yellow-600 border-yellow-500/20";
      case "Critical":
        return "bg-red-500/10 text-red-600 border-red-500/20";
      default:
        return "bg-slate-500/10 text-slate-600 border-slate-500/20";
    }
  };

  return (
    <div className="flex flex-col gap-6 h-full">
      <div className="flex justify-between items-center">
        <h2 className="text-lg font-semibold text-slate-700 dark:text-slate-200 uppercase tracking-tight">
          Sistem Sağlığı
        </h2>
        <div className={cn(
          "px-3 py-1 rounded-full text-xs font-bold border transition-colors",
          getStatusColor(data.status)
        )}>
          {data.status}
        </div>
      </div>

      <div className="flex flex-col gap-4">
        <div className="flex items-center gap-3 group">
          <div className="p-2 rounded-lg bg-blue-50 dark:bg-blue-500/10 text-blue-500 group-hover:scale-110 transition-transform">
            <Clock className="w-4 h-4" />
          </div>
          <div className="flex flex-col">
            <span className="text-sm font-medium text-slate-700 dark:text-slate-300">Uptime</span>
            <span className="text-xs text-muted-foreground whitespace-nowrap">Son {data.uptimeHours} saattir aktif</span>
          </div>
        </div>

        <div className="flex items-center gap-3 group">
          <div className="p-2 rounded-lg bg-purple-50 dark:bg-purple-500/10 text-purple-500 group-hover:scale-110 transition-transform">
            <Activity className="w-4 h-4" />
          </div>
          <div className="flex flex-col">
            <span className="text-sm font-medium text-slate-700 dark:text-slate-300">Yanıt Süresi</span>
            <span className="text-xs text-muted-foreground whitespace-nowrap">Ortalama {data.averageResponseTimeMs} ms</span>
          </div>
        </div>

        <div className="flex items-center gap-3 group">
          <div className={cn(
            "p-2 rounded-lg transition-transform group-hover:scale-110",
            data.errorCountLast24Hours > 0 
                ? "bg-amber-50 dark:bg-amber-500/10 text-amber-500" 
                : "bg-green-50 dark:bg-green-500/10 text-green-500"
          )}>
            {data.errorCountLast24Hours > 0 ? <AlertTriangle className="w-4 h-4" /> : <Server className="w-4 h-4" />}
          </div>
          <div className="flex flex-col">
            <span className="text-sm font-medium text-slate-700 dark:text-slate-300">Hatalar (24s)</span>
            <span className="text-xs text-muted-foreground whitespace-nowrap">
                {data.errorCountLast24Hours === 0 ? "Hiç hata saptanmadı" : `${data.errorCountLast24Hours} adet hata saptandı`}
            </span>
          </div>
        </div>
      </div>

      <p className="text-[10px] text-muted-foreground italic mt-auto leading-tight">
        Sistem kaynaklı tüm operasyonel veriler canlı olarak izlenmektedir.
      </p>
    </div>
  );
};

export default HealthCheckWidget;
