"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import apiClient from "@/lib/axios";
import { DailyContentDto } from "@/types/dto";
import { ContentType } from "@/types/enums";
import { Button } from "@/components/ui/button";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";

const getContentTypeName = (type: ContentType) => {
    switch (type) {
        case ContentType.Verse: return "Ayet";
        case ContentType.Hadith: return "Hadis";
        case ContentType.Quote: return "Söz";
        case ContentType.Prayer: return "Dua";
        default: return type;
    }
};

export default function DailyContentsPage() {
    const [contents, setContents] = useState<DailyContentDto[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchContents = async () => {
        try {
            const { data } = await apiClient.get<DailyContentDto[]>("/DailyContents");
            setContents(data);
        } catch (error) {
            console.error("İçerikler getirilemedi:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchContents();
    }, []);

    const handleDelete = async (id: string) => {
        if (!confirm("Emin misiniz?")) return;
        try {
            await apiClient.delete(`/DailyContents/${id}`);
            fetchContents();
        } catch (error) {
            console.error("Silme hatası:", error);
        }
    };

    return (
        <div className="p-8 space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Günlük İçerikler</h1>
                <Link href="/daily-contents/create">
                    <Button>Yeni İçerik Ekle</Button>
                </Link>
            </div>

            <div className="border rounded-md bg-white dark:bg-zinc-900 border-zinc-200 dark:border-zinc-800">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Başlık</TableHead>
                            <TableHead>Tür</TableHead>
                            <TableHead>Tarih</TableHead>
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
                        ) : contents.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8 text-zinc-500">
                                    Kayıt bulunamadı.
                                </TableCell>
                            </TableRow>
                        ) : (
                            contents.map((item) => (
                                <TableRow key={item.id}>
                                    <TableCell className="font-medium">{item.title}</TableCell>
                                    <TableCell>{getContentTypeName(item.type)}</TableCell>
                                    <TableCell>{item.date}</TableCell>
                                    <TableCell className="text-right space-x-2">
                                        <Link href={`/daily-contents/${item.id}/edit`}>
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
