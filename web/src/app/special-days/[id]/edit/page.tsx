"use client";

import { useEffect, useState, use } from "react";
import { useRouter } from "next/navigation";
import apiClient from "@/lib/axios";
import { SpecialDayDto } from "@/types/dto";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export default function EditSpecialDayPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = use(params);
    const [name, setName] = useState("");
    const [date, setDate] = useState("");
    const [description, setDescription] = useState("");
    const [loading, setLoading] = useState(false);
    const [fetching, setFetching] = useState(true);
    const router = useRouter();

    useEffect(() => {
        const fetchDay = async () => {
            try {
                const { data } = await apiClient.get<SpecialDayDto>(`/SpecialDays/${id}`);
                setName(data.name);
                setDate(data.date);
                setDescription(data.description);
            } catch (error) {
                console.error("Özel gün yüklenirken hata:", error);
            } finally {
                setFetching(false);
            }
        };
        fetchDay();
    }, [id]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            await apiClient.put(`/SpecialDays/${id}`, { id, name, date, description });
            router.push("/special-days");
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
            <h1 className="text-3xl font-bold">Özel Gün Düzenle</h1>
            <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                    <Label htmlFor="name">Adı</Label>
                    <Input
                        id="name"
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                        required
                    />
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
                <div className="space-y-2">
                    <Label htmlFor="description">Açıklama</Label>
                    <Textarea
                        id="description"
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
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
