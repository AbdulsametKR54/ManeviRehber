"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import { apiSettings } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Edit, Trash2, Plus } from "lucide-react";

export default function SettingsPage() {
    const [settings, setSettings] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchSettings = async () => {
        try {
            setLoading(true);
            const res = await apiSettings.getAll();
            setSettings(res.data?.items || res.data || []);
        } catch (error) {
            console.error("Failed to fetch settings", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchSettings();
    }, []);

    const handleDelete = async (id: string) => {
        if (!confirm("Bu ayarı silmek istediğinize emin misiniz?")) return;
        try {
            await apiSettings.delete(id);
            fetchSettings();
        } catch (error) {
            console.error("Silme işlemi başarısız", error);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Sistem Ayarları</h1>
                    <p className="text-muted-foreground mt-1">Uygulamanın genel ayarlarını yönetin (Örn: Versiyon, Bakım Modu vb.).</p>
                </div>
                <Link href="/dashboard/settings/create" className="w-full sm:w-auto">
                    <Button className="gap-2 w-full sm:w-auto">
                        <Plus className="h-4 w-4" />
                        Yeni Ayar Ekle
                    </Button>
                </Link>
            </div>

            <div className="rounded-lg border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 shadow-sm p-6 mt-6">
                <h2 className="text-xl font-semibold mb-6">Ayarlar Listesi</h2>
                <div className="mt-4">
                    <div className="overflow-x-auto">
                        {loading ? (
                            <div className="p-8 text-center text-muted-foreground animate-pulse">Yükleniyor...</div>
                        ) : settings.length === 0 ? (
                            <div className="p-8 text-center text-muted-foreground">Kayıtlı ayar bulunamadı.</div>
                        ) : (
                            <table className="w-full border-separate border-spacing-0 text-sm">
                                <thead>
                                    <tr>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Anahtar (Key)</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Değer (Value)</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Açıklama</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Son Güncelleme</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-right px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İşlemler</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {settings.map((s, i) => (
                                        <tr
                                            key={s.id}
                                            className={`
                                                ${i % 2 === 0 ? "bg-white dark:bg-gray-900" : "bg-gray-50 dark:bg-gray-800"}
                                                hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors
                                            `}
                                        >
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-semibold">{s.key}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 text-muted-foreground truncate max-w-[200px]">{s.value}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 text-muted-foreground">{s.description}</td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 text-muted-foreground whitespace-nowrap">
                                                {s.updatedAt ? format(new Date(s.updatedAt), 'dd MMM yyyy HH:mm', { locale: tr }) : '-'}
                                            </td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 text-right">
                                                <div className="flex justify-end gap-3 h-full min-h-[40px] items-center">
                                                    <Link href={`/dashboard/settings/edit/${s.id}`}>
                                                        <button className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 transition-colors">
                                                            <Edit className="h-4 w-4" />
                                                        </button>
                                                    </Link>
                                                    <button
                                                        className="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 transition-colors"
                                                        onClick={() => handleDelete(s.id)}
                                                    >
                                                        <Trash2 className="h-4 w-4" />
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
