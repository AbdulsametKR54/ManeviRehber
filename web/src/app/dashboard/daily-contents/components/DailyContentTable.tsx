"use client";

import Link from "next/link";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Edit, Trash2 } from "lucide-react";
import { apiDailyContent } from "@/lib/api";

interface DailyContentTableProps {
    contents: any[];
    loading: boolean;
    error: string | null;
    onRefresh: () => void;
    page: number;
    pageSize: number;
    totalCount: number;
    onPageChange: (page: number) => void;
    onPageSizeChange: (pageSize: number) => void;
}

export function DailyContentTable({ contents, loading, error, onRefresh, page, pageSize, totalCount, onPageChange, onPageSizeChange }: DailyContentTableProps) {
    const handleDelete = async (id: string) => {
        if (!confirm("Bu içeriği silmek istediğinize emin misiniz?")) return;
        try {
            await apiDailyContent.delete(id);
            onRefresh();
        } catch (error) {
            console.error("Silme işlemi başarısız", error);
        }
    };

    if (loading) {
        return (
            <div className="w-full">
                <table className="w-full border-separate border-spacing-0 text-sm">
                    <thead>
                        <tr>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Tarih</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Başlık</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İçerik</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Tip</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Kategoriler</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Özel Gün</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-right px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colSpan={7} className="text-center py-8 text-muted-foreground animate-pulse border-b border-gray-200 dark:border-gray-700">
                                Yükleniyor...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        );
    }

    if (error) {
        return (
            <div className="mb-4 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 p-3 rounded-md border border-red-200 dark:border-red-800/30 text-sm">
                {error}
            </div>
        );
    }

    if (contents.length === 0) {
        return (
            <div className="w-full">
                <table className="w-full border-separate border-spacing-0 text-sm">
                    <thead>
                        <tr>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Tarih</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Başlık</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İçerik</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Tip</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Kategoriler</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Özel Gün</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-right px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colSpan={7} className="text-center py-8 text-muted-foreground border-b border-gray-200 dark:border-gray-700">
                                Kayıt bulunamadı.
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        );
    }

    return (
        <div className="w-full overflow-x-auto">
            <table className="w-full border-separate border-spacing-0 text-sm">
                <thead>
                    <tr>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Tarih</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Başlık</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İçerik</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Tip</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Kategoriler</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Özel Gün</th>
                            <th className="bg-gray-50 dark:bg-gray-800 text-right px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İşlemler</th>
                    </tr>
                </thead>
                <tbody>
                    {contents.map((c, i) => {
                        const getTypeName = (type: number) => {
                            switch (type) {
                                case 1: return "Ayet";
                                case 2: return "Hadis";
                                case 3: return "Söz";
                                case 4: return "Dua";
                                default: return "Bilinmeyen";
                            }
                        };

                        return (
                            <tr
                                key={c.id}
                                className={`
                                        ${i % 2 === 0 ? "bg-white dark:bg-gray-900" : "bg-gray-50 dark:bg-gray-800"}
                                        hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors
                                    `}
                            >
                                <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                    {c.date ? format(new Date(c.date), 'dd MMMM yyyy', { locale: tr }) : '-'}
                                </td>
                                <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-medium truncate max-w-[200px]" title={c.title}>
                                    {c.title}
                                </td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 truncate max-w-[200px]" title={c.content}>
                                {c.content?.length > 50 ? `${c.content.substring(0, 50)}...` : c.content}
                            </td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                <span className="inline-flex items-center rounded-md bg-gray-100 dark:bg-gray-700 px-2 py-1 text-xs font-medium text-gray-700 dark:text-gray-200">
                                    {getTypeName(c.type)}
                                </span>
                            </td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                {c.categories && c.categories.length > 0 ? (
                                    <div className="flex flex-wrap gap-2">
                                        {c.categories.map((cat: any) => (
                                            <span
                                                key={cat.id}
                                                className="inline-flex items-center rounded-md bg-gray-100 dark:bg-gray-700 px-2 py-1 text-xs font-medium text-gray-700 dark:text-gray-200"
                                            >
                                                {cat.name}
                                            </span>
                                        ))}
                                    </div>
                                ) : (
                                    <span className="text-gray-400">-</span>
                                )}
                            </td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                {c.specialDayName ? (
                                    <span className="inline-flex items-center rounded-md bg-blue-100 dark:bg-blue-900 px-2 py-1 text-xs font-medium text-blue-700 dark:text-blue-200">
                                        {c.specialDayName}
                                    </span>
                                ) : (
                                    <span className="text-gray-400">-</span>
                                )}
                            </td>
                                <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 flex items-center justify-end gap-3 h-full min-h-[50px]">
                                    <Link href={`/dashboard/daily-contents/edit/${c.id}`}>
                                        <button className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 transition-colors" title="Düzenle">
                                            <Edit className="h-4 w-4" />
                                        </button>
                                    </Link>
                                    <button
                                        onClick={() => handleDelete(c.id)}
                                        className="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 transition-colors"
                                        title="Sil"
                                    >
                                        <Trash2 className="h-4 w-4" />
                                    </button>
                                </td>
                            </tr>
                        );
                    })}
                </tbody>
            </table>
        </div>
    );
}
