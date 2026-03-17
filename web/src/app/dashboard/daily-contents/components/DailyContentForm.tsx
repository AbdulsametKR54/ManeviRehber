"use client";

import { useState, useEffect } from "react";
import { useRouter, useParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { apiDailyContent, apiCategory, apiSpecialDay } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage, FormDescription } from "@/components/ui/form";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { ArrowLeft } from "lucide-react";

// Matches API request schemas: CreateDailyContentCommand
const dailyContentSchema = z.object({
    title: z.string().min(1, "Başlık zorunludur"),
    content: z.string().min(5, "İçerik en az 5 karakter olmalıdır"),
    type: z.number().min(1, "İçerik tipi zorunludur"),
    date: z.string().min(1, "Tarih zorunludur"),
    specialDayId: z.string().nullable().optional(),
    categoryIds: z.array(z.string()),
});

type DailyContentFormValues = z.infer<typeof dailyContentSchema>;

export function DailyContentForm() {
    const router = useRouter();
    const params = useParams();
    const id = params?.id as string;
    const isEditing = !!id;

    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [categories, setCategories] = useState<any[]>([]);
    const [specialDays, setSpecialDays] = useState<any[]>([]);

    const form = useForm<DailyContentFormValues>({
        resolver: zodResolver(dailyContentSchema),
        defaultValues: {
            title: "",
            content: "",
            type: 1, // 1: Ayet, 2: Hadis, 3: Söz, 4: Dua
            date: new Date().toISOString().split("T")[0],
            specialDayId: null,
            categoryIds: [],
        },
    });

    useEffect(() => {
        const fetchInitialData = async () => {
            try {
                const [catRes, sdRes] = await Promise.all([
                    apiCategory.getAll(),
                    apiSpecialDay.getAll()
                ]);
                setCategories(catRes.data?.items || catRes.data || []);
                setSpecialDays(sdRes.data?.items || sdRes.data || []);

                if (isEditing) {
                    const res = await apiDailyContent.getById(id);
                    const data = res.data;
                    form.reset({
                        title: data.title || "",
                        content: data.content || "",
                        type: data.type || 1,
                        date: data.date ? data.date.split("T")[0] : "",
                        specialDayId: data.specialDayId || null,
                        categoryIds: data.categories?.map((c: any) => c.id) || [],
                    });
                }
            } catch (error) {
                console.error("Fetch form data error", error);
            } finally {
                setLoading(false);
            }
        };
        fetchInitialData();
    }, [id, form, isEditing]);

    const onSubmit = async (data: DailyContentFormValues) => {
        setSaving(true);
        try {
            const payload = {
                id: isEditing ? id : undefined,
                title: data.title,
                content: data.content,
                type: data.type,
                date: data.date,
                specialDayId: data.specialDayId || null,
                categoryIds: data.categoryIds || []
            };

            if (isEditing) {
                await apiDailyContent.update(id, payload);
            } else {
                await apiDailyContent.create(payload);
            }
            router.push("/dashboard/daily-contents");
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
                <CardTitle>{isEditing ? "İçerik Düzenle" : "Yeni İçerik Ekle"}</CardTitle>
            </CardHeader>
            <CardContent>
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">

                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <FormField
                                control={form.control}
                                name="title"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Başlık</FormLabel>
                                        <FormControl>
                                            <Input placeholder="Başlık giriniz..." {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="type"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>İçerik Tipi</FormLabel>
                                        <Select onValueChange={(val) => field.onChange(Number(val))} value={field.value ? field.value.toString() : "1"}>
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="İçerik Tipini Seçin" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value="1">Ayet</SelectItem>
                                                <SelectItem value="2">Hadis</SelectItem>
                                                <SelectItem value="3">Söz</SelectItem>
                                                <SelectItem value="4">Dua</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="specialDayId"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Özel Gün (İsteğe Bağlı)</FormLabel>
                                        <Select
                                            onValueChange={(val) => field.onChange(val === "none" ? null : val)}
                                            value={field.value || "none"}
                                        >
                                            <FormControl>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="Özel Gün Seçin (Opsiyonel)" />
                                                </SelectTrigger>
                                            </FormControl>
                                            <SelectContent>
                                                <SelectItem value="none">Özel Gün Yok</SelectItem>
                                                {specialDays.map((sd) => (
                                                    <SelectItem key={sd.id} value={sd.id}>
                                                        {sd.title || sd.name}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />
                        </div>

                        <FormField
                            control={form.control}
                            name="categoryIds"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>Kategoriler</FormLabel>
                                    <div className="flex flex-wrap gap-2 border border-gray-200 dark:border-gray-800 rounded-md p-3 max-h-40 overflow-y-auto bg-background">
                                        {categories.map((c) => {
                                            const isSelected = field.value.includes(c.id);
                                            return (
                                                <Badge
                                                    key={c.id}
                                                    variant={isSelected ? "default" : "outline"}
                                                    className="cursor-pointer transition-colors"
                                                    onClick={() => {
                                                        if (isSelected) {
                                                            field.onChange(field.value.filter((id) => id !== c.id));
                                                        } else {
                                                            field.onChange([...field.value, c.id]);
                                                        }
                                                    }}
                                                >
                                                    {c.name}
                                                </Badge>
                                            )
                                        })}
                                        {categories.length === 0 && <span className="text-sm text-muted-foreground">Kategori bulunamadı.</span>}
                                    </div>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="content"
                            render={({ field }) => (
                                <FormItem>
                                    <FormLabel>İçerik Metni</FormLabel>
                                    <FormControl>
                                        <Textarea rows={5} placeholder="İçerik metnini buraya giriniz..." {...field} />
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
