"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { apiCategory } from "@/lib/api";
import { Category } from "@/types/models";
import { Button } from "@/components/ui/button";
import { SearchBar } from "@/components/ui/SearchBar";
import { Pagination } from "@/components/ui/Pagination";
import { Plus, Edit, Trash2 } from "lucide-react";

export default function CategoryPage() {
    const [categories, setCategories] = useState<Category[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    // Pagination & Search state
    const [search, setSearch] = useState("");
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(10);
    const [totalCount, setTotalCount] = useState(0);

    const fetchCategories = async () => {
        try {
            setLoading(true);
            setError(null);
            const { data } = await apiCategory.getPaged(search, page, pageSize);
            if (data?.items) {
                setCategories(data.items);
                setTotalCount(data.totalCount);
                if (data.page) setPage(data.page);
                if (data.pageSize) setPageSize(data.pageSize);
            } else {
                setCategories(data || []);
            }
        } catch (error) {
            console.error("Kategoriler getirilemedi:", error);
            setError("Veriler yüklenirken bir hata oluştu.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchCategories();
    }, [search, page, pageSize]);

    const handleSearchChange = (val: string) => {
        setSearch(val);
        setPage(1); // Reset page on search
    };

    const handlePageSizeChange = (size: number) => {
        setPageSize(size);
        setPage(1); // Reset page on size change
    };

    const handleDelete = async (id: string) => {
        if (!confirm("Emin misiniz?")) return;
        try {
            await apiCategory.delete(id);
            fetchCategories();
        } catch (error) {
            console.error("Silme hatası:", error);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Kategoriler</h1>
                    <p className="text-muted-foreground mt-1">İçeriklerinizi gruplandırmak için kategorileri yönetin.</p>
                </div>
                <Link href="/dashboard/categories/create">
                    <Button className="gap-2 w-full sm:w-auto">
                        <Plus className="h-4 w-4" />
                        Yeni Kategori Ekle
                    </Button>
                </Link>
            </div>

            <div className="rounded-lg border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 shadow-sm p-6 mt-6">
                <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-4">
                    <h2 className="text-xl font-semibold">Kategori Listesi</h2>
                    <SearchBar value={search} onChange={handleSearchChange} placeholder="Kategori ara..." />
                </div>
                
                {error && (
                    <div className="mb-4 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 p-3 rounded-md border border-red-200 dark:border-red-800/30 text-sm">
                        {error}
                    </div>
                )}

                <div className="mt-4 overflow-x-auto">
                    <table className="w-full border-separate border-spacing-0 text-sm">
                        <thead>
                            <tr>
                                <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Adı</th>
                                <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Açıklama</th>
                                <th className="bg-gray-50 dark:bg-gray-800 text-right px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İşlemler</th>
                            </tr>
                        </thead>
                        <tbody>
                            {loading ? (
                                <tr>
                                    <td colSpan={3} className="text-center py-8 text-muted-foreground animate-pulse border-b border-gray-200 dark:border-gray-700">
                                        Yükleniyor...
                                    </td>
                                </tr>
                            ) : categories.length === 0 ? (
                                <tr>
                                    <td colSpan={3} className="text-center py-8 text-muted-foreground border-b border-gray-200 dark:border-gray-700">
                                        Kayıt bulunamadı.
                                    </td>
                                </tr>
                            ) : (
                                categories.map((item, i) => (
                                    <tr
                                        key={item.id}
                                        className={`
                                            ${i % 2 === 0 ? "bg-white dark:bg-gray-900" : "bg-gray-50 dark:bg-gray-800"}
                                            hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors
                                        `}
                                    >
                                        <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-medium">
                                            <span className="inline-flex items-center rounded-md bg-gray-100 dark:bg-gray-700 px-2 py-1 text-xs font-medium text-gray-700 dark:text-gray-200">
                                                {item.name}
                                            </span>
                                        </td>
                                        <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 text-muted-foreground">
                                            {item.description}
                                        </td>
                                        <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                            <div className="flex items-center justify-end gap-3 h-full min-h-[50px]">
                                                <Link href={`/dashboard/categories/${item.id}/edit`}>
                                                    <button className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 transition-colors" title="Düzenle">
                                                        <Edit className="h-4 w-4" />
                                                    </button>
                                                </Link>
                                                <button
                                                    onClick={() => handleDelete(item.id)}
                                                    className="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 transition-colors"
                                                    title="Sil"
                                                >
                                                    <Trash2 className="h-4 w-4" />
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>

                {!loading && !error && categories.length > 0 && (
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
