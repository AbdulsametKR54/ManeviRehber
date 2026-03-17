"use client";

import { useEffect, useState, use } from "react";
import { useRouter } from "next/navigation";
import apiClient from "@/lib/axios";
import { DailyContentDto } from "@/types/dto";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export default function EditDailyContentPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = use(params);
    const [title, setTitle] = useState("");
    const [content, setContent] = useState("");
    const [type, setType] = useState<number>(1);
    const [date, setDate] = useState("");
    const [loading, setLoading] = useState(false);
    const [fetching, setFetching] = useState(true);
    const router = useRouter();

    useEffect(() => {
        const fetchContent = async () => {
            try {
                const { data } = await apiClient.get<DailyContentDto>(`/DailyContents/${id}`);
                setTitle(data.title);
                setContent(data.content);
                setType(data.type);
                // data.date is expected to be "YYYY-MM-DD"
                setDate(data.date);
            } catch (error) {
                console.error("İçerik yüklenirken hata:", error);
            } finally {
                setFetching(false);
            }
        };
        fetchContent();
    }, [id]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            await apiClient.put(`/DailyContents/${id}`, {
                id,
                title,
                content,
                type: Number(type),
                date
            });
            router.push("/daily-contents");
            router.refresh();
        } catch (error) {
            console.error("Güncelleme hatası:", error);
            alert("Bir hata oluştu.");
        } finally {
            setLoading(false);
        }
    };

    if (fetching) return <div className="p-8">Yükleniyor...</div>;

    return (
        <div className="max-w-xl mx-auto p-8 space-y-6">
            <h1 className="text-3xl font-bold">Günlük İçerik Düzenle</h1>
            <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                    <Label htmlFor="title">Başlık</Label>
                    <Input
                        id="title"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        required
                    />
                </div>
                <div className="space-y-2">
                    <Label htmlFor="content">İçerik</Label>
                    <Textarea
                        id="content"
                        value={content}
                        onChange={(e) => setContent(e.target.value)}
                        required
                    />
                </div>
                <div className="space-y-2">
                    <Label htmlFor="type">Tür</Label>
                    <select
                        id="type"
                        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        value={type}
                        onChange={(e) => setType(Number(e.target.value))}
                        required
                    >
                        <option value={1}>Ayet</option>
                        <option value={2}>Hadis</option>
                        <option value={3}>Söz</option>
                        <option value={4}>Dua</option>
                    </select>
                </div>
                <div className="space-y-2">
                    <Label htmlFor="date">Tarih</Label>
                    <Input
                        id="date"
                        type="date"
                        value={date}
                        onChange={(e) => setDate(e.target.value)}
                        required
                    />
                </div>
                <div className="flex gap-2">
                    <Button type="button" variant="outline" onClick={() => router.back()}>
                        İptal
                    </Button>
                    <Button type="submit" disabled={loading}>
                        {loading ? "Güncelleniyor..." : "Güncelle"}
                    </Button>
                </div>
            </form>
        </div>
    );
}
