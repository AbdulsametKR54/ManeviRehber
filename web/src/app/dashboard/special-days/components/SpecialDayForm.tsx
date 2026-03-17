"use client";

import { useState, useEffect } from "react";
import { useRouter, useParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { apiSpecialDay } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { ArrowLeft } from "lucide-react";

const specialDaySchema = z.object({
    name: z.string().min(2, "Başlık en az 2 karakter olmalıdır"),
    description: z.string().min(5, "Açıklama en az 5 karakter olmalıdır"),
    date: z.string().min(1, "Tarih zorunludur"),
});

type SpecialDayFormValues = z.infer<typeof specialDaySchema>;

export function SpecialDayForm() {
    const router = useRouter();
    const params = useParams();
    const id = params?.id as string;
    const isEditing = !!id;

    const [loading, setLoading] = useState(isEditing);
    const [saving, setSaving] = useState(false);

    const form = useForm<SpecialDayFormValues>({
        resolver: zodResolver(specialDaySchema),
        defaultValues: {
            name: "",
            description: "",
            date: "",
        },
    });

    useEffect(() => {
        if (isEditing) {
            const fetchData = async () => {
                try {
                    const res = await apiSpecialDay.getById(id);
                    const data = res.data;
                    form.reset({
                        name: data.name || "",
                        description: data.description || "",
                        // Format dates simply for input type="date"
                        date: data.date ? data.date.split("T")[0] : "",
                    });
                } catch (error) {
                    console.error("Fetch special day error", error);
                } finally {
                    setLoading(false);
                }
            };
            fetchData();
        }
    }, [id, form, isEditing]);

    const onSubmit = async (data: SpecialDayFormValues) => {
        setSaving(true);
        try {
            if (isEditing) {
                await apiSpecialDay.update(id, { id, ...data });
            } else {
                await apiSpecialDay.create(data);
            }
            router.push("/dashboard/special-days");
            router.refresh();
        } catch (error) {
            console.error("Kaydetme hatası", error);
        } finally {
            setSaving(false);
        }
    };

    if (loading) return <div>Yükleniyor...</div>;

    return (
        <Card className="max-w-3xl">
            <CardHeader className="flex flex-row items-center gap-4 space-y-0">
                <Button variant="ghost" size="icon" onClick={() => router.back()}>
                    <ArrowLeft className="h-4 w-4" />
                </Button>
                <CardTitle>{isEditing ? "Gün Düzenle" : "Yeni Gün Ekle"}</CardTitle>
            </CardHeader>
            <CardContent>
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <FormField
                            control={form.control}
                            name="name"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Başlık</FormLabel>
                                    <FormControl>
                                        <Input placeholder="Örn: Regaip Kandili" {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="date"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Tarih</FormLabel>
                                    <FormControl>
                                        <Input type="date" {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="description"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Açıklama</FormLabel>
                                    <FormControl>
                                        <Textarea rows={4} placeholder="Günün kısa anlamı/aşlık..." {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="flex justify-end gap-2 pt-4">
                            <Button type="button" variant="outline" onClick={() => router.back()}>
                                İptal
                            </Button>
                            <Button type="submit" disabled={saving}>
                                {saving ? "Kaydediliyor..." : "Değişiklikleri Kaydet"}
                            </Button>
                        </div>
                    </form>
                </Form>
            </CardContent>
        </Card>
    );
}
