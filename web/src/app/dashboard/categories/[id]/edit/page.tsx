"use client";

import { useEffect, useState, use } from "react";
import { useRouter } from "next/navigation";
import apiClient from "@/lib/axios";
import { Category } from "@/types/models";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export default function EditCategoryPage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = use(params);
    const [name, setName] = useState("");
    const [description, setDescription] = useState("");
    const [loading, setLoading] = useState(false);
    const [fetching, setFetching] = useState(true);
    const router = useRouter();

    useEffect(() => {
        const fetchCategory = async () => {
            try {
                const { data } = await apiClient.get<Category[]>("/Category");
                const category = data.find(c => c.id === id);
                if (category) {
                    setName(category.name);
                    setDescription(category.description || "");
                }
            } catch (error) {
                console.error("Kategori yüklenirken hata:", error);
            } finally {
                setFetching(false);
            }
        };
        fetchCategory();
    }, [id]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            await apiClient.put(`/Category/${id}`, { id, name, description });
            router.push("/dashboard/categories");
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
            <h1 className="text-3xl font-bold">Kategori Düzenle</h1>
            <form onSubmit={handleSubmit} className="border border-gray-200 dark:border-gray-800 rounded-lg p-4 space-y-4">
                <div className="space-y-2">
                    <Label htmlFor="name">Kategori Adı</Label>
                    <Input
                        id="name"
                        value={name}
                        onChange={(e) => setName(e.target.value)}
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
