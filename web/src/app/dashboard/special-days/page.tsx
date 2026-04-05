"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { apiSpecialDay } from "@/lib/api";
import { SpecialDayTable } from "./components/SpecialDayTable";
import { SearchBar } from "@/components/ui/SearchBar";
import { Pagination } from "@/components/ui/Pagination";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";

export default function SpecialDayPage() {
    const [specialDays, setSpecialDays] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Pagination & Search state
    const [search, setSearch] = useState("");
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(10);
    const [totalCount, setTotalCount] = useState(0);

    const fetchSpecialDays = useCallback(async () => {
        try {
            setLoading(true);
            setError(null);
            const res = await apiSpecialDay.getPagedSpecialDays(search, page, pageSize);
            if (res.data?.items) {
                setSpecialDays(res.data.items);
                setTotalCount(res.data.totalCount);
                if (res.data.page && res.data.page !== page) setPage(res.data.page);
                if (res.data.pageSize && res.data.pageSize !== pageSize) setPageSize(res.data.pageSize);
            } else {
                setSpecialDays(Array.isArray(res.data) ? res.data : []);
            }
        } catch (error) {
            console.error("Failed to fetch special days", error);
            setError("Veriler yüklenirken bir hata oluştu.");
        } finally {
            setLoading(false);
        }
    }, [search, page, pageSize]);

    useEffect(() => {
        fetchSpecialDays();
    }, [fetchSpecialDays]);

    const handleSearchChange = useCallback((val: string) => {
        setSearch(val);
        setPage(1); // Reset page on search
    }, []);

    const handlePageSizeChange = useCallback((size: number) => {
        setPageSize(size);
        setPage(1); // Reset page on size change
    }, []);

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Önemli Günler</h1>
                    <p className="text-muted-foreground mt-1">Kandiller, bayramlar ve diğer önemli dini günleri yönetin.</p>
                </div>
                <Link href="/dashboard/special-days/create" className="w-full sm:w-auto">
                    <Button className="gap-2 w-full sm:w-auto">
                        <Plus className="h-4 w-4" />
                        Yeni Gün Ekle
                    </Button>
                </Link>
            </div>

            <div className="rounded-lg border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 shadow-sm p-6 mt-6">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-4">
                    <h2 className="text-xl font-semibold">Önemli Günler Listesi</h2>
                    <SearchBar value={search} onChange={handleSearchChange} placeholder="Önemli gün ara..." />
                </div>
                
                <div className="mt-4 overflow-x-auto">
                    <SpecialDayTable 
                        specialDays={specialDays} 
                        loading={loading} 
                        error={error}
                        onRefresh={fetchSpecialDays} 
                        page={page}
                        pageSize={pageSize}
                        totalCount={totalCount}
                        onPageChange={setPage}
                        onPageSizeChange={handlePageSizeChange}
                    />
                </div>
                
                {!loading && !error && specialDays.length > 0 && (
                    <Pagination
                        totalCount={totalCount}
                        page={page}
                        pageSize={pageSize}
                        onPageChange={setPage}
                        onPageSizeChange={handlePageSizeChange}
                    />
                )}
            </div>
        </div>
    );
}
