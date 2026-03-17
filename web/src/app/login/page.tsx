"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import apiClient from "@/lib/axios";
import { setToken, useAuthStore } from "@/lib/auth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export default function LoginPage() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const router = useRouter();

    // Kullanıcı logini hızlandırmak için dashboard'u prefetch et
    useEffect(() => {
        router.prefetch("/dashboard");
    }, [router]);

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError(null);

        try {
            const response = await apiClient.post("/Auth/login", {
                email,
                password,
            });

            const { token } = response.data;
            if (token) {
                const { name, email, id } = response.data;
                const store = useAuthStore.getState();

                // Decode token to get role
                let role = "User";
                try {
                    const base64Url = token.split('.')[1];
                    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
                    const jsonPayload = decodeURIComponent(atob(base64).split('').map(function (c) {
                        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
                    }).join(''));
                    const payload = JSON.parse(jsonPayload);
                    role = payload?.role || payload?.["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"] || "User";
                } catch (e) {
                    console.error("JWT Decode error", e);
                }

                store.setToken(token);
                store.setUser({ name, email, id, role });

                // Set cookie for Next.js proxy middleware to detect
                document.cookie = `token=${token}; path=/; max-age=86400; SameSite=Lax`;

                router.push("/dashboard");
            } else {
                setError("Token alınamadı.");
            }
        } catch (err: any) {
            setError(err.response?.data?.message || "Giriş başarısız.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-background text-foreground p-4 transition-colors duration-300">
            <div className="w-full max-w-[440px] bg-card text-card-foreground rounded-[2rem] shadow-lg overflow-hidden border border-border p-8 sm:p-12 transition-all">

                {/* Logo and Header */}
                <div className="mb-10 text-center flex flex-col items-center">
                    <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center mb-6 text-primary">
                        {/* Dummy Logo Icon */}
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-8 h-8">
                            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" />
                        </svg>
                    </div>
                    <h1 className="text-3xl font-black text-foreground tracking-tight">Manevi <span className="text-primary font-bold">REHBER</span></h1>
                    <p className="mt-3 text-sm font-medium text-muted-foreground">Yönetim paneline hoş geldiniz.</p>
                </div>

                {/* Form */}
                <form onSubmit={handleLogin} className="space-y-6">
                    <div className="space-y-2">
                        <Label htmlFor="email" className="text-foreground ml-1">E-posta Adresi</Label>
                        <Input
                            id="email"
                            type="email"
                            className="bg-input border-border text-foreground h-12 rounded-xl focus:ring-primary/20 transition-all px-4"
                            placeholder="ornek@mail.com"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required
                        />
                    </div>

                    <div className="space-y-2">
                        <div className="flex items-center justify-between ml-1">
                            <Label htmlFor="password" className="text-foreground">Şifre</Label>
                            {/* Optional: <a href="#" className="text-xs text-primary hover:underline font-medium">Şifremi Unuttum?</a> */}
                        </div>
                        <Input
                            id="password"
                            type="password"
                            className="bg-input border-border text-foreground h-12 rounded-xl focus:ring-primary/20 transition-all px-4"
                            placeholder="••••••••"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                        />
                    </div>

                    {error && (
                        <div className="p-3 bg-destructive/10 border border-destructive/20 rounded-xl text-center">
                            <p className="text-sm font-medium text-destructive">{error}</p>
                        </div>
                    )}

                    <Button
                        type="submit"
                        size="lg"
                        className="w-full bg-primary hover:bg-primary/90 text-white h-12 rounded-xl text-base font-semibold shadow-lg shadow-primary/20 transition-all focus:ring-4 focus:ring-primary/20"
                        disabled={loading}
                    >
                        {loading ? "Giriş yapılıyor..." : "Giriş Yap"}
                    </Button>
                </form>

                {/* Footer link if needed */}
                {/* <div className="mt-8 text-center text-sm text-slate-500">
                    Hesabınız yok mu? <a href="#" className="text-primary font-semibold hover:underline">Destek ile iletişime geçin</a>
                </div> */}
            </div>
        </div>
    );
}
