"use client";

import Link from "next/link";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Send, Users } from "lucide-react";

export default function NotificationsPage() {
    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Bildirim Yönetimi</h1>
                <p className="text-muted-foreground">Kullanıcılara push veya uygulama içi bildirimler gönderin.</p>
            </div>

            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Users className="h-5 w-5 text-primary" />
                            Tüm Kullanıcılara Gönder
                        </CardTitle>
                        <CardDescription>
                            Uygulamaya kayıtlı tüm kullanıcılara genel bir duyuru veya bildirim gönderin.
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <Link href="/dashboard/notifications/send">
                            <Button className="w-full gap-2">
                                <Send className="h-4 w-4" />
                                Toplu Bildirim Oluştur
                            </Button>
                        </Link>
                    </CardContent>
                </Card>

                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Send className="h-5 w-5 text-primary" />
                            Belirli Kullanıcıya Gönder
                        </CardTitle>
                        <CardDescription>
                            Kullanıcı listesinden id seçerek, o kişiye özel bildirim iletin. (İleride eklenebilir)
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <Link href="/dashboard/users">
                            <Button variant="outline" className="w-full gap-2">
                                <Users className="h-4 w-4" />
                                Kullanıcı Listesine Git
                            </Button>
                        </Link>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
