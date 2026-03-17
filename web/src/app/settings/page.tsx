"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import apiClient from "@/lib/axios";
import { SettingDto } from "@/types/dto";
import { Button } from "@/components/ui/button";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";

export default function SettingsPage() {
    const [settings, setSettings] = useState<SettingDto[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchSettings = async () => {
        try {
            const { data } = await apiClient.get<SettingDto[]>("/Settings");
            setSettings(data);
        } catch (error) {
            console.error("Ayarlar getirilemedi:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchSettings();
    }, []);

    const handleDelete = async (id: string) => {
        if (!confirm("Emin misiniz?")) return;
        try {
            await apiClient.delete(`/Settings/${id}`);
            fetchSettings();
        } catch (error) {
            console.error("Silme hatası:", error);
        }
    };

    return (
        <div className="p-8 space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Ayarlar</h1>
                <Link href="/settings/create">
                    <Button>Yeni Ayar Ekle</Button>
                </Link>
            </div>

            <div className="border rounded-md bg-white dark:bg-zinc-900 border-zinc-200 dark:border-zinc-800">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Anahtar (Key)</TableHead>
                            <TableHead>Değer (Value)</TableHead>
                            <TableHead>Açıklama</TableHead>
                            <TableHead className="text-right">İşlemler</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8">
                                    Yükleniyor...
                                </TableCell>
                            </TableRow>
                        ) : settings.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8 text-zinc-500">
                                    Kayıt bulunamadı.
                                </TableCell>
                            </TableRow>
                        ) : (
                            settings.map((item) => (
                                <TableRow key={item.id}>
                                    <TableCell className="font-medium">{item.key}</TableCell>
                                    <TableCell>{item.value}</TableCell>
                                    <TableCell>{item.description}</TableCell>
                                    <TableCell className="text-right space-x-2">
                                        <Link href={`/settings/${item.id}/edit`}>
                                            <Button variant="outline" size="sm">Düzenle</Button>
                                        </Link>
                                        <Button
                                            variant="destructive"
                                            size="sm"
                                            onClick={() => handleDelete(item.id)}
                                        >
                                            Sil
                                        </Button>
                                    </TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
