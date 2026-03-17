"use client";

import { useEffect, useState } from "react";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import { apiLogs } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Eye, Search, Filter } from "lucide-react";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";

export default function LogsPage() {
    const [logs, setLogs] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [filterAction, setFilterAction] = useState("");

    const fetchLogs = async () => {
        try {
            setLoading(true);
            const params: any = {};
            if (searchTerm) params.userId = searchTerm; // Assuming GUID search
            if (filterAction) params.action = filterAction;

            const res = await apiLogs.getAll(params);
            setLogs(res.data?.items || res.data || []);
        } catch (error) {
            console.error("Failed to fetch logs", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchLogs();
    }, [searchTerm, filterAction]);

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Sistem Logları</h1>
                    <p className="text-muted-foreground mt-1">Adminlerin yaptığı değişiklikleri ve hassas işlemleri izleyin.</p>
                </div>
            </div>

            <div className="rounded-lg border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 shadow-sm p-6 mt-6">
                <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6">
                    <h2 className="text-xl font-semibold">Log Kayıtları</h2>
                    <div className="flex flex-wrap sm:flex-nowrap gap-2 w-full sm:w-auto">
                        <div className="relative flex-1 sm:flex-none">
                            <Search className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                            <Input
                                type="search"
                                placeholder="User ID ile ara..."
                                className="pl-9 w-full sm:w-[250px] bg-white dark:bg-slate-950 focus:ring-primary/20"
                                value={searchTerm}
                                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearchTerm(e.target.value)}
                            />
                        </div>
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="outline" className="gap-2 bg-white dark:bg-slate-950 w-full sm:w-auto">
                                    <Filter className="h-4 w-4" />
                                    <span>Eylem Filtresi</span>
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                                <DropdownMenuItem onClick={() => setFilterAction("")}>
                                    Tümü
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setFilterAction("User.Login")}>
                                    Oturum (Login)
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setFilterAction("DailyContent")}>
                                    Günlük İçerik
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setFilterAction("User.")}>
                                    Kullanıcı İşlemleri
                                </DropdownMenuItem>
                                <DropdownMenuItem onClick={() => setFilterAction("Setting.")}>
                                    Sistem Ayarları
                                </DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                    </div>
                </div>

                <div className="mt-4">
                    <div className="overflow-x-auto">
                        {loading ? (
                            <div className="p-8 text-center text-muted-foreground animate-pulse">Yükleniyor...</div>
                        ) : logs.length === 0 ? (
                            <div className="p-8 text-center text-muted-foreground">Uygun log kaydı bulunamadı.</div>
                        ) : (
                            <table className="w-full border-separate border-spacing-0 text-sm">
                                <thead>
                                    <tr>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Tarih</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Eylem (Action)</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Kullanıcı ID</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Açıklama</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">IP Adresi</th>
                                        <th className="bg-gray-50 dark:bg-gray-800 text-right px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Detay (JSON)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {logs.map((log, i) => (
                                        <tr
                                            key={log.id}
                                            className={`
                                                ${i % 2 === 0 ? "bg-white dark:bg-gray-900" : "bg-gray-50 dark:bg-gray-800"}
                                                hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors
                                            `}
                                        >
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 whitespace-nowrap text-muted-foreground">
                                                {log.createdAt ? format(new Date(log.createdAt), 'dd MMM yy HH:mm', { locale: tr }) : '-'}
                                            </td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                                <span className="inline-flex items-center rounded-md bg-primary/5 text-primary px-2 py-1 text-xs font-mono">
                                                    {log.action}
                                                </span>
                                            </td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-mono text-xs max-w-[120px] truncate text-muted-foreground" title={log.userId}>
                                                {log.userId}
                                            </td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 truncate max-w-[200px] text-muted-foreground" title={log.description}>
                                                {log.description}
                                            </td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-mono text-xs text-muted-foreground">
                                                {log.ipAddress}
                                            </td>
                                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                                <div className="flex items-center justify-end h-full min-h-[50px]">
                                                    <button
                                                        className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 transition-colors"
                                                        onClick={() => alert(`JSON Data:\n${log.data}`)}
                                                    >
                                                        <Eye className="h-4 w-4" />
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
