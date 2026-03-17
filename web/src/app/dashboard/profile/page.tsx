"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { apiAuth, apiUsers } from "@/lib/api";
import { useAuthStore } from "@/lib/auth";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

export default function ProfilePage() {
    const { user, setUser } = useAuthStore();
    const router = useRouter();

    const [loadingName, setLoadingName] = useState(false);
    const [loadingEmail, setLoadingEmail] = useState(false);
    const [loadingLang, setLoadingLang] = useState(false);
    const [loadingPass, setLoadingPass] = useState(false);

    // Schemas
    const nameSchema = z.object({ name: z.string().min(2, "İsim en az 2 karakter olmalıdır.") });
    const emailSchema = z.object({ email: z.string().email("Geçerli bir email adresi girin.") });
    const langSchema = z.object({ language: z.string().min(1, "Dil seçimi zorunlu.") });
    const passSchema = z.object({
        oldPassword: z.string().min(1, "Mevcut şifre gerekli."),
        newPassword: z.string().min(6, "Yeni şifre en az 6 karakter olmalı.")
    });

    // Forms
    const formName = useForm({ resolver: zodResolver(nameSchema), defaultValues: { name: user?.name || "" } });
    const formEmail = useForm({ resolver: zodResolver(emailSchema), defaultValues: { email: user?.email || "" } });
    const formLang = useForm({ resolver: zodResolver(langSchema), defaultValues: { language: "TR" } }); // Default to TR if not in user
    const formPass = useForm({ resolver: zodResolver(passSchema), defaultValues: { oldPassword: "", newPassword: "" } });

    const handleSuccess = (message: string) => {
        toast.success("Başarılı", {
            description: message,
        });
    };

    const handleError = (error: any) => {
        if (error.response?.status === 401) {
            router.push("/login");
        } else if (error.response?.status === 400) {
            toast.error("Hata", {
                description: error.response.data?.Message || "Lütfen girdiğiniz bilgileri kontrol edin.",
            });
        } else {
            toast.error("Hata", {
                description: "Sunucu ile iletişimde bir sorun oluştu.",
            });
        }
    };

    const updateAuthStore = (updates: any) => {
        if (user) {
            setUser({ ...user, ...updates });
        }
    };

    const onSubmitName = async (data: z.infer<typeof nameSchema>) => {
        setLoadingName(true);
        try {
            await apiAuth.updateName(data);
            handleSuccess("İsim başarıyla güncellendi.");
            updateAuthStore({ name: data.name });
            formName.reset({ name: data.name });
        } catch (error) {
            handleError(error);
        } finally {
            setLoadingName(false);
        }
    };

    const onSubmitEmail = async (data: z.infer<typeof emailSchema>) => {
        setLoadingEmail(true);
        try {
            await apiUsers.updateProfile({ email: data.email });
            handleSuccess("Email başarıyla güncellendi.");
            updateAuthStore({ email: data.email });
            formEmail.reset({ email: data.email });
        } catch (error) {
            handleError(error);
        } finally {
            setLoadingEmail(false);
        }
    };

    const onSubmitLang = async (data: z.infer<typeof langSchema>) => {
        setLoadingLang(true);
        try {
            await apiAuth.updateLanguage(data);
            handleSuccess("Dil başarıyla güncellendi.");
            formLang.reset({ language: data.language });
        } catch (error) {
            handleError(error);
        } finally {
            setLoadingLang(false);
        }
    };

    const onSubmitPass = async (data: z.infer<typeof passSchema>) => {
        setLoadingPass(true);
        try {
            // We only send the new password since UpdateProfileCommand only takes Password
            await apiUsers.updateProfile({ password: data.newPassword });
            handleSuccess("Şifre başarıyla güncellendi.");
            formPass.reset();
        } catch (error) {
            handleError(error);
        } finally {
            setLoadingPass(false);
        }
    };

    return (
        <div className="space-y-6 max-w-4xl mx-auto pb-10">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Profilim</h1>
                <p className="text-muted-foreground mt-2">Kendi bilgilerinizi, dil tercihinizi ve şifrenizi buradan yönetebilirsiniz.</p>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                {/* NAME FORM */}
                <Card className="hover:shadow-md transition-shadow">
                    <CardHeader>
                        <CardTitle>İsim Güncelle</CardTitle>
                        <CardDescription>Profil adınızı değiştirin.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <Form {...formName}>
                            <form onSubmit={formName.handleSubmit(onSubmitName)} className="space-y-4">
                                <FormField
                                    control={formName.control}
                                    name="name"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Ad Soyad</FormLabel>
                                            <FormControl>
                                                <Input {...field} className="focus:ring-primary/20" />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <Button type="submit" disabled={loadingName} className="w-full sm:w-auto">
                                    {loadingName ? "Güncelleniyor..." : "İsmi Güncelle"}
                                </Button>
                            </form>
                        </Form>
                    </CardContent>
                </Card>

                {/* EMAIL FORM */}
                <Card className="hover:shadow-md transition-shadow">
                    <CardHeader>
                        <CardTitle>Email Güncelle</CardTitle>
                        <CardDescription>Giriş e-posta adresinizi değiştirin.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <Form {...formEmail}>
                            <form onSubmit={formEmail.handleSubmit(onSubmitEmail)} className="space-y-4">
                                <FormField
                                    control={formEmail.control}
                                    name="email"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Email Adresi</FormLabel>
                                            <FormControl>
                                                <Input type="email" {...field} className="focus:ring-primary/20" />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <Button type="submit" disabled={loadingEmail} className="w-full sm:w-auto">
                                    {loadingEmail ? "Güncelleniyor..." : "Email Güncelle"}
                                </Button>
                            </form>
                        </Form>
                    </CardContent>
                </Card>

                {/* LANGUAGE FORM */}
                <Card className="hover:shadow-md transition-shadow">
                    <CardHeader>
                        <CardTitle>Dil Güncelle</CardTitle>
                        <CardDescription>Arayüz dil tercihini belirleyin.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <Form {...formLang}>
                            <form onSubmit={formLang.handleSubmit(onSubmitLang)} className="space-y-4">
                                <FormField
                                    control={formLang.control}
                                    name="language"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Dil</FormLabel>
                                            <Select onValueChange={field.onChange} defaultValue={field.value}>
                                                <FormControl>
                                                    <SelectTrigger className="focus:ring-primary/20">
                                                        <SelectValue placeholder="Dil seçin" />
                                                    </SelectTrigger>
                                                </FormControl>
                                                <SelectContent>
                                                    <SelectItem value="TR">Türkçe (TR)</SelectItem>
                                                    <SelectItem value="EN">İngilizce (EN)</SelectItem>
                                                </SelectContent>
                                            </Select>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <Button type="submit" disabled={loadingLang} className="w-full sm:w-auto">
                                    {loadingLang ? "Güncelleniyor..." : "Dili Güncelle"}
                                </Button>
                            </form>
                        </Form>
                    </CardContent>
                </Card>

                {/* PASSWORD FORM */}
                <Card className="hover:shadow-md transition-shadow">
                    <CardHeader>
                        <CardTitle>Şifre Güncelle</CardTitle>
                        <CardDescription>Hesabınızın şifresini değiştirin.</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <Form {...formPass}>
                            <form onSubmit={formPass.handleSubmit(onSubmitPass)} className="space-y-4">
                                <FormField
                                    control={formPass.control}
                                    name="oldPassword"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Mevcut Şifre</FormLabel>
                                            <FormControl>
                                                <Input type="password" {...field} className="focus:ring-primary/20" />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <FormField
                                    control={formPass.control}
                                    name="newPassword"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Yeni Şifre</FormLabel>
                                            <FormControl>
                                                <Input type="password" {...field} className="focus:ring-primary/20" />
                                            </FormControl>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                                <Button type="submit" disabled={loadingPass} className="w-full sm:w-auto">
                                    {loadingPass ? "Güncelleniyor..." : "Şifreyi Güncelle"}
                                </Button>
                            </form>
                        </Form>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
