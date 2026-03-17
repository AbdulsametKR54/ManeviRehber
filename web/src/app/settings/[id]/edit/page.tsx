"use client";

import { useEffect, useState, use } from "react";
import { useRouter } from "next/navigation";
import apiClient from "@/lib/axios";
import { SettingDto } from "@/types/dto";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export default function EditSettingPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = use(params);
    const [key, setKey] = useState("");
    const [value, setValue] = useState("");
    const [description, setDescription] = useState("");
    const [loading, setLoading] = useState(false);
    const [fetching, setFetching] = useState(true);
    const router = useRouter();

    useEffect(() => {
        const fetchSetting = async () => {
            try {
                const { data } = await apiClient.get<SettingDto>(`/Settings/${id}`);
                setKey(data.key);
                setValue(data.value);
                setDescription(data.description || "");
            } catch (error) {
                console.error("Ayar yüklenirken hata:", error);
            } finally {
                setFetching(false);
            }
        };
        fetchSetting();
    }, [id]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            await apiClient.put(`/Settings/${id}`, { id, key, value, description });
            router.push("/settings");
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
            <h1 className="text-3xl font-bold">Ayar Düzenle</h1>
            <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                    <Label htmlFor="key">Anahtar (Key)</Label>
                    <Input
                        id="key"
                        value={key}
                        onChange={(e) => setKey(e.target.value)}
                        required
                    />
                </div>
                <div className="space-y-2">
                    <Label htmlFor="value">Değer (Value)</Label>
                    <Input
                        id="value"
                        value={value}
                        onChange={(e) => setValue(e.target.value)}
                        required
                    />
                </div>
                <div className="space-y-2">
                    <Label htmlFor="description">Açıklama</Label>
                    <Textarea
                        id="description"
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
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
