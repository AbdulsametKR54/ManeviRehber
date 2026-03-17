"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { apiDailyContent, apiCategory, apiSpecialDay } from "@/lib/api";
import { DailyContentTable } from "./components/DailyContentTable";
import { SearchBar } from "@/components/ui/SearchBar";
import { Pagination } from "@/components/ui/Pagination";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";

export default function DailyContentPage() {
    const [contents, setContents] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Filter states
    const [search, setSearch] = useState("");
    const [date, setDate] = useState("");
    const [type, setType] = useState<number | "">("");
    const [categoryId, setCategoryId] = useState("");
    const [specialDayId, setSpecialDayId] = useState("");

    // Pagination states
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(10);
    const [totalCount, setTotalCount] = useState(0);

    // Options for selects
    const [categories, setCategories] = useState<any[]>([]);
    const [specialDays, setSpecialDays] = useState<any[]>([]);

    useEffect(() => {
        // Fetch categories and special days for filters
        apiCategory.getAll().then(res => setCategories(res.data)).catch(console.error);
        apiSpecialDay.getAll().then(res => setSpecialDays(res.data?.items || res.data || [])).catch(console.error);
    }, []);

    const fetchContents = async () => {
        try {
            setLoading(true);
            setError(null);
            const res = await apiDailyContent.getPagedDailyContents({
                search,
                date: date || undefined,
                type: type === "" ? undefined : type,
                categoryId: categoryId || undefined,
                specialDayId: specialDayId || undefined,
                page,
                pageSize
            });
            if (res.data?.items) {
                setContents(res.data.items);
                setTotalCount(res.data.totalCount);
                if (res.data.page) setPage(res.data.page);
                if (res.data.pageSize) setPageSize(res.data.pageSize);
            } else {
                setContents(res.data || []);
            }
        } catch (error) {
            console.error("Failed to fetch daily contents", error);
            setError("Veriler yüklenirken bir hata oluştu.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchContents();
    }, [search, date, type, categoryId, specialDayId, page, pageSize]);

    const handleFilterChange = () => {
        setPage(1);
    };

    const handleSearchChange = (val: string) => {
        setSearch(val);
        handleFilterChange();
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Günlük İçerikler</h1>
                    <p className="text-muted-foreground mt-1">Kullanıcılara gösterilecek günlük dua, hadis, ayet vb. içerikleri yönetin.</p>
                </div>
                <Link href="/dashboard/daily-contents/create" className="w-full sm:w-auto">
                    <Button className="gap-2 w-full sm:w-auto">
                        <Plus className="h-4 w-4" />
                        Yeni İçerik Ekle
                    </Button>
                </Link>
            </div>

            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 shadow-sm p-4 sm:p-6 mt-6">
                <div className="mb-6 space-y-4">
                    <h2 className="text-xl font-semibold">İçerik Listesi</h2>
                    
                    {/* Filters */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
                        <div className="lg:col-span-1 rounded-md">
                            <SearchBar value={search} onChange={handleSearchChange} placeholder="İçerik ara..." />
                        </div>
                        <input
                            type="date"
                            value={date}
                            onChange={(e) => { setDate(e.target.value); handleFilterChange(); }}
                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        />
                        <select
                            value={type}
                            onChange={(e) => { setType(e.target.value === "" ? "" : Number(e.target.value)); handleFilterChange(); }}
                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            <option value="">Tüm Tipler</option>
                            <option value={1}>Ayet</option>
                            <option value={2}>Hadis</option>
                            <option value={3}>Söz</option>
                            <option value={4}>Dua</option>
                        </select>
                        <select
                            value={categoryId}
                            onChange={(e) => { setCategoryId(e.target.value); handleFilterChange(); }}
                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            <option value="">Tüm Kategoriler</option>
                            {categories.map((cat: any) => (
                                <option key={cat.id} value={cat.id}>{cat.name}</option>
                            ))}
                        </select>
                        <select
                            value={specialDayId}
                            onChange={(e) => { setSpecialDayId(e.target.value); handleFilterChange(); }}
                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            <option value="">Tüm Önemli Günler</option>
                            {specialDays.map((sd: any) => (
                                <option key={sd.id} value={sd.id}>{sd.title || sd.name}</option>
                            ))}
                        </select>
                    </div>
                </div>

                <div className="mt-4 overflow-x-auto">
                    <DailyContentTable 
                        contents={contents} 
                        loading={loading}
                        error={error} 
                        onRefresh={fetchContents}
                        page={page}
                        pageSize={pageSize}
                        totalCount={totalCount}
                        onPageChange={setPage}
                        onPageSizeChange={(size) => { setPageSize(size); setPage(1); }}
                    />
                </div>
                
                {!loading && !error && contents.length > 0 && (
                    <Pagination
                        totalCount={totalCount}
                        page={page}
                        pageSize={pageSize}
                        onPageChange={setPage}
                        onPageSizeChange={(size) => { setPageSize(size); setPage(1); }}
                    />
                )}
            </div>
        </div>
    );
}
