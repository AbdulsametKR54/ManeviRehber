"use client";

import { useState, useEffect } from "react";
import { useRouter, useParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { apiSettings } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage, FormDescription } from "@/components/ui/form";
import { ArrowLeft } from "lucide-react";

const settingSchema = z.object({
    key: z.string().min(1, "Anahtar zorunludur (örneğin: MaintenanceMode)"),
    value: z.string().min(1, "Değer zorunludur (örneğin: true)"),
    description: z.string().optional(),
});

type SettingFormValues = z.infer<typeof settingSchema>;

export function SettingsForm() {
    const router = useRouter();
    const params = useParams();
    const id = params?.id as string;
    const isEditing = !!id;

    const [loading, setLoading] = useState(isEditing);
    const [saving, setSaving] = useState(false);

    const form = useForm<SettingFormValues>({
        resolver: zodResolver(settingSchema),
        defaultValues: {
            key: "",
            value: "",
            description: "",
        },
    });

    useEffect(() => {
        if (isEditing) {
            const fetchData = async () => {
                try {
                    const res = await apiSettings.getById(id);
                    const data = res.data;
                    form.reset({
                        key: data.key || "",
                        value: data.value || "",
                        description: data.description || "",
                    });
                } catch (error) {
                    console.error("Fetch setting error", error);
                } finally {
                    setLoading(false);
                }
            };
            fetchData();
        }
    }, [id, form, isEditing]);

    const onSubmit = async (data: SettingFormValues) => {
        setSaving(true);
        try {
            if (isEditing) {
                await apiSettings.update(id, { id, ...data });
            } else {
                await apiSettings.create(data);
            }
            router.push("/dashboard/settings");
            router.refresh();
        } catch (error) {
            console.error("Ayarlar güncellenirken hata oluştu", error);
        } finally {
            setSaving(false);
        }
    };

    if (loading) return <div>Yükleniyor...</div>;

    return (
        <Card className="max-w-2xl">
            <CardHeader className="flex flex-row items-center gap-4 space-y-0">
                <Button variant="ghost" size="icon" onClick={() => router.back()}>
                    <ArrowLeft className="h-4 w-4" />
                </Button>
                <CardTitle>{isEditing ? "Ayar Düzenle" : "Yeni Ayar Ekle"}</CardTitle>
            </CardHeader>
            <CardContent>
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <FormField
                            control={form.control}
                            name="key"
                            render={({ field }: { field: any }) => (
                                <FormItem>
                                    <FormLabel>Anahtar (Key)</FormLabel>
                                    <FormDescription>Sistem tarafında kodu yazanların okuduğu karşılıktır. Dikkatli değiştiriniz.</FormDescription>
                                    <FormControl>
                                        <Input {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="value"
                            render={({ field }: { field: any }) => (
                                <FormItem>
                                    <FormLabel>Değer (Value)</FormLabel>
                                    <FormDescription>JSON veya düz metin olabilir (Örn: true, v1.0.0, {`{ "isOpen": false }`})</FormDescription>
                                    <FormControl>
                                        <Input {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="description"
                            render={({ field }: { field: any }) => (
                                <FormItem>
                                    <FormLabel>Açıklama (Opsiyonel)</FormLabel>
                                    <FormControl>
                                        <Textarea rows={3} placeholder="Bu ayarın ne işe yaradığı..." {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <div className="flex justify-end gap-2 pt-4">
                            <Button type="button" variant="outline" onClick={() => router.back()}>
                                İptal
                            </Button>
                            <Button type="submit" disabled={saving || !form.formState.isDirty}>
                                {saving ? "Güncelleniyor..." : "Güncelle"}
                            </Button>
                        </div>
                    </form>
                </Form>
            </CardContent>
        </Card>
    );
}
