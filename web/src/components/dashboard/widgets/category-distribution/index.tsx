"use client";

import React from "react";
import useSWR from "swr";
import { fetcher } from "@/lib/fetcher";
import { useDashboardWidgetsStore } from '@/store/dashboard-widgets';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  Cell
} from "recharts";
import { CategoryDistributionSkeleton } from "./skeleton";

interface CategoryCount {
  categoryName: string;
  count: number;
}

const CategoryDistributionWidget = () => {
  const { autoRefresh, autoRefreshInterval } = useDashboardWidgetsStore();
  const isRefreshing = autoRefresh["categoryDistribution"] ?? false;
  const interval = autoRefreshInterval["categoryDistribution"] ?? 60000;

  const { data, error, isLoading } = useSWR<CategoryCount[]>(
    "/dashboard/category-counts", 
    (url: string) => fetcher<CategoryCount[]>(url),
    {
      refreshInterval: isRefreshing ? interval : 0
    }
  );

  if (isLoading) return <CategoryDistributionSkeleton />;
  if (error) return <div className="text-sm text-red-500 font-medium">Veri alınamadı</div>;
  if (!data || data.length === 0) return <div className="text-sm text-muted-foreground italic flex items-center h-full">Kategori verisi bulunamadı</div>;

  // Sadece ilk 8 kategoriyi gösterelim ki chart çok kalabalık olmasın
  const chartData = data.slice(0, 8);

  return (
    <div className="flex flex-col gap-4 h-full">
      <h2 className="text-lg font-semibold text-slate-700 dark:text-slate-200 uppercase tracking-tight">
        Kategori Bazlı İçerik Sayısı
      </h2>
      
      <div className="h-48 w-full mt-2">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={chartData} margin={{ top: 5, right: 10, left: -20, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" opacity={0.5} />
            <XAxis 
              dataKey="categoryName" 
              axisLine={false} 
              tickLine={false} 
              tick={{ fontSize: 9, fill: "#94A3B8" }} 
              interval={0}
              angle={-25}
              textAnchor="end"
              height={50}
            />
            <YAxis 
              axisLine={false} 
              tickLine={false} 
              tick={{ fontSize: 9, fill: "#94A3B8" }} 
            />
            <Tooltip 
              cursor={{ fill: 'rgba(0,0,0,0.05)' }}
              contentStyle={{ 
                borderRadius: "8px", 
                border: "none", 
                boxShadow: "0 10px 15px -3px rgb(0 0 0 / 0.1)",
                fontSize: "12px",
                fontWeight: "bold"
              }}
            />
            <Bar 
              dataKey="count" 
              radius={[4, 4, 0, 0]}
              animationDuration={1500}
            >
              {chartData.map((_entry, index) => (
                <Cell key={`cell-${index}`} fill={index % 2 === 0 ? "#10b981" : "#0ea5e9"} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>

      <p className="text-xs text-muted-foreground italic mt-auto">
        Tüm kategorilerdeki içerik dağılımı
      </p>
    </div>
  );
};

export default CategoryDistributionWidget;
