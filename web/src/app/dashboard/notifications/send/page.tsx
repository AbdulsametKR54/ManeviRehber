"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { ArrowLeft } from "lucide-react";

const notificationSchema = z.object({
    title: z.string().min(2, "Başlık zorunludur"),
    message: z.string().min(5, "Mesaj zorunludur"),
});

type NotificationFormValues = z.infer<typeof notificationSchema>;

export default function SendNotificationPage() {
    const router = useRouter();
    const [saving, setSaving] = useState(false);

    const form = useForm<NotificationFormValues>({
        resolver: zodResolver(notificationSchema),
        defaultValues: {
            title: "",
            message: "",
        },
    });

    const onSubmit = async (data: NotificationFormValues) => {
        setSaving(true);
        try {
            // TODO: Connect this to actual Firebase/Push Notification endpoint when API is ready
            console.log("Mock sending notification: ", data);
            alert("Bildirim simüle edildi (API ucu yok)");
            router.push("/dashboard/notifications");
        } catch (error) {
            console.error("Gönderme hatası", error);
        } finally {
            setSaving(false);
        }
    };

    return (
        <Card className="max-w-2xl">
            <CardHeader className="flex flex-row items-center gap-4 space-y-0">
                <Button variant="ghost" size="icon" onClick={() => router.back()}>
                    <ArrowLeft className="h-4 w-4" />
                </Button>
                <div>
                    <CardTitle>Toplu Bildirim Gönder</CardTitle>
                    <CardDescription>Tüm kullanıcılara anında bildirim gidecektir.</CardDescription>
                </div>
            </CardHeader>
            <CardContent>
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <FormField
                            control={form.control}
                            name="title"
                            render={({ field }: { field: any }) => (
                                <FormItem>
                                    <FormLabel>Bildirim Başlığı</FormLabel>
                                    <FormControl>
                                        <Input placeholder="Örn: Yeni İçerik Eklendi!" {...field} />
                                    </FormControl>
                                    <FormMessage />
                                </FormItem>
                            )}
                        />

                        <FormField
                            control={form.control}
                            name="message"
                            render={({ field }: { field: any }) => (
                                <FormItem>
                                    <FormLabel>Bildirim İçeriği</FormLabel>
                                    <FormControl>
                                        <Textarea rows={4} placeholder="Detaylı mesajınız..." {...field} />
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
                                {saving ? "Gönderiliyor..." : "Hemen Gönder"}
                            </Button>
                        </div>
                    </form>
                </Form>
            </CardContent>
        </Card>
    );
}
