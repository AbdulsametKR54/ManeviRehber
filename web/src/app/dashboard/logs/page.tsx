"use client";

import { useEffect, useState } from "react";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import { apiLogs } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Eye, Search, Filter, Monitor, Smartphone, Globe } from "lucide-react";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter, DialogClose } from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";

// Custom hook to detect media query matches
function useMediaQuery(query: string): boolean {
    const [matches, setMatches] = useState(false);

    useEffect(() => {
        const media = window.matchMedia(query);
        const updateMatches = () => setMatches(media.matches);
        
        // Initial check
        updateMatches();
        
        // Listen for changes
        media.addEventListener("change", updateMatches);
        return () => media.removeEventListener("change", updateMatches);
    }, [query]);

    return matches;
}

export default function LogsPage() {
    const [logs, setLogs] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");
    const [filterAction, setFilterAction] = useState("");

    const [selectedLog, setSelectedLog] = useState<any>(null);
    const [isDetailOpen, setIsDetailOpen] = useState(false);
    const [viewMode, setViewMode] = useState<'list' | 'grouped'>('list');
    const isDesktop = useMediaQuery("(min-width: 768px)");

    // Grouping logic
    const groupedLogs = logs.reduce((acc: any[], log: any) => {
        const existing = acc.find(item => item.userId === log.userId);
        if (existing) {
            existing.count += 1;
            if (new Date(log.createdAt) > new Date(existing.lastActivity)) {
                existing.lastActivity = log.createdAt;
                existing.lastAction = log.action;
                existing.platform = log.platform;
            }
        } else {
            acc.push({
                userId: log.userId,
                count: 1,
                lastActivity: log.createdAt,
                lastAction: log.action,
                platform: log.platform
            });
        }
        return acc;
    }, []);

    const fetchLogs = async () => {
        try {
            setLoading(true);
            const params: any = {};
            if (searchTerm) params.userId = searchTerm; // Assuming GUID search
            if (filterAction) params.action = filterAction;

            const res = await apiLogs.getAll(params);
            setLogs((res.data as any)?.items || res.data || []);
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
                    <div className="flex items-center gap-4">
                        <h2 className="text-xl font-semibold">Log Kayıtları</h2>
                        <div className="flex bg-muted rounded-md p-1">
                            <Button 
                                variant={viewMode === 'list' ? 'secondary' : 'ghost'} 
                                size="sm" 
                                className="h-8 px-3 text-xs"
                                onClick={() => setViewMode('list')}
                            >
                                Liste
                            </Button>
                            <Button 
                                variant={viewMode === 'grouped' ? 'secondary' : 'ghost'} 
                                size="sm" 
                                className="h-8 px-3 text-xs"
                                onClick={() => setViewMode('grouped')}
                            >
                                Gruplanmış (User ID)
                            </Button>
                        </div>
                    </div>
                    <div className="flex flex-wrap sm:flex-nowrap gap-2 w-full sm:w-auto">
                        {(searchTerm || filterAction) && (
                            <Button 
                                variant="ghost" 
                                size="sm" 
                                className="h-10 px-3 text-muted-foreground hover:text-foreground"
                                onClick={() => {
                                    setSearchTerm("");
                                    setFilterAction("");
                                }}
                            >
                                Temizle
                            </Button>
                        )}
                        <div className="relative flex-1 sm:flex-none">
                            <Search className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                            <Input
                                type="search"
                                placeholder={viewMode === 'grouped' ? "User ID'yi gruplarda ara..." : "User ID ile ara..."}
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

                <div className="mt-4 overflow-hidden border rounded-md">
                    {loading ? (
                        <div className="p-8 text-center text-muted-foreground animate-pulse">Yükleniyor...</div>
                    ) : (logs.length === 0 || (viewMode === 'grouped' && groupedLogs.length === 0)) ? (
                        <div className="p-8 text-center text-muted-foreground">Uygun log kaydı bulunamadı.</div>
                    ) : (
                        <div className="w-full overflow-x-auto custom-scrollbar">
                            {viewMode === 'list' ? (
                                <Table className="min-w-[1000px]">
                                    <TableHeader>
                                        <TableRow className="bg-muted/50 hover:bg-muted/50">
                                            <TableHead className="w-[150px]">Tarih</TableHead>
                                            <TableHead>Eylem</TableHead>
                                            <TableHead>Kullanıcı ID</TableHead>
                                            <TableHead>Platform</TableHead>
                                            <TableHead>Endpoint</TableHead>
                                            <TableHead className="max-w-[200px]">Açıklama</TableHead>
                                            <TableHead>IP Adresi</TableHead>
                                            <TableHead className="text-right">Detay</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {logs.map((log) => (
                                            <TableRow key={log.id} className="group transition-colors">
                                                <TableCell className="text-xs text-muted-foreground whitespace-nowrap">
                                                    {log.createdAt ? format(new Date(log.createdAt), 'dd MMM yy HH:mm', { locale: tr }) : '-'}
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant="outline" className="bg-primary/5 text-primary text-[10px] font-mono whitespace-nowrap">
                                                        {log.action}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell className="font-mono text-[11px] truncate max-w-[120px]" title={log.userId}>
                                                    <span 
                                                        className="cursor-pointer hover:text-primary hover:underline underline-offset-4 decoration-dotted"
                                                        onClick={() => {
                                                            setSearchTerm(log.userId);
                                                            setViewMode('list');
                                                        }}
                                                    >
                                                        {log.userId?.split('-')[0]}...
                                                    </span>
                                                </TableCell>
                                                <TableCell>
                                                    <div className="flex items-center gap-1.5">
                                                        {log.platform === 'Mobile' ? (
                                                            <Smartphone className="h-3.5 w-3.5 text-emerald-500" />
                                                        ) : log.platform === 'Web' ? (
                                                            <Monitor className="h-3.5 w-3.5 text-blue-500" />
                                                        ) : (
                                                            <Globe className="h-3.5 w-3.5 text-gray-400" />
                                                        )}
                                                        <span className="text-xs">{log.platform || 'System'}</span>
                                                    </div>
                                                </TableCell>
                                                <TableCell className="font-mono text-[11px] truncate max-w-[150px]" title={log.endpoint}>
                                                    {log.endpoint}
                                                </TableCell>
                                                <TableCell className="text-xs text-muted-foreground max-w-[200px] truncate" title={log.description}>
                                                    {log.description}
                                                </TableCell>
                                                <TableCell className="font-mono text-[11px] text-muted-foreground">
                                                    {log.ipAddress}
                                                </TableCell>
                                                <TableCell className="text-right">
                                                    <Button
                                                        variant="ghost"
                                                        size="icon"
                                                        className="h-8 w-8 text-muted-foreground group-hover:text-primary transition-colors"
                                                        onClick={() => {
                                                            setSelectedLog(log);
                                                            setIsDetailOpen(true);
                                                        }}
                                                    >
                                                        <Eye className="h-4 w-4" />
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            ) : (
                                <Table className="min-w-full">
                                    <TableHeader>
                                        <TableRow className="bg-muted/50 hover:bg-muted/50">
                                            <TableHead>Kullanıcı ID</TableHead>
                                            <TableHead>Cihaz / Platform</TableHead>
                                            <TableHead className="text-center">İşlem Sayısı</TableHead>
                                            <TableHead>Son Eylem</TableHead>
                                            <TableHead>Son Görülme</TableHead>
                                            <TableHead className="text-right">İncele</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {groupedLogs.map((group) => (
                                            <TableRow 
                                                key={group.userId} 
                                                className="cursor-pointer hover:bg-muted/30 transition-colors"
                                                onClick={() => {
                                                    setSearchTerm(group.userId);
                                                    setViewMode('list');
                                                }}
                                            >
                                                <TableCell className="font-mono text-sm font-medium">
                                                    {group.userId || 'Anonim'}
                                                </TableCell>
                                                <TableCell>
                                                    <div className="flex items-center gap-1.5">
                                                        {group.platform === 'Mobile' ? (
                                                            <Smartphone className="h-4 w-4 text-emerald-500" />
                                                        ) : group.platform === 'Web' ? (
                                                            <Monitor className="h-4 w-4 text-blue-500" />
                                                        ) : (
                                                            <Globe className="h-4 w-4 text-gray-400" />
                                                        )}
                                                        <span className="text-xs">{group.platform || 'System'}</span>
                                                    </div>
                                                </TableCell>
                                                <TableCell className="text-center">
                                                    <Badge variant="secondary" className="px-2 py-0.5">
                                                        {group.count}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <span className="text-xs px-2 py-0.5 rounded bg-muted">
                                                        {group.lastAction}
                                                    </span>
                                                </TableCell>
                                                <TableCell className="text-xs text-muted-foreground whitespace-nowrap">
                                                    {group.lastActivity ? format(new Date(group.lastActivity), 'dd MMMM yyyy HH:mm', { locale: tr }) : '-'}
                                                </TableCell>
                                                <TableCell className="text-right">
                                                    <Button variant="outline" size="sm" className="h-8 text-[10px] uppercase tracking-wide">
                                                        Logs ({group.count})
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            )}
                        </div>
                    )}
                </div>
            </div>

            <Dialog open={isDetailOpen} onOpenChange={setIsDetailOpen}>
                <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle className="flex items-center gap-2">
                            <Badge variant="outline" className="font-mono text-[10px] uppercase">
                                {selectedLog?.action}
                            </Badge>
                            Log Detayları
                        </DialogTitle>
                        <DialogDescription>
                            {selectedLog?.createdAt ? format(new Date(selectedLog.createdAt), 'dd MMMM yyyy HH:mm:ss', { locale: tr }) : '-'}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="space-y-4 py-4">
                        <div className="grid grid-cols-2 gap-4 text-sm">
                            <div className="space-y-1">
                                <span className="text-muted-foreground block text-[10px] uppercase font-bold">Kullanıcı ID</span>
                                <code className="bg-muted px-1 rounded text-xs select-all">{selectedLog?.userId || 'Anonim'}</code>
                            </div>
                            <div className="space-y-1">
                                <span className="text-muted-foreground block text-[10px] uppercase font-bold">Platform / IP</span>
                                <div className="flex items-center gap-2">
                                    <Badge variant="secondary" className="px-1 h-5 text-[10px]">
                                        {selectedLog?.platform || 'System'}
                                    </Badge>
                                    <span className="text-xs font-mono">{selectedLog?.ipAddress}</span>
                                </div>
                            </div>
                        </div>

                        <div className="space-y-1">
                            <span className="text-muted-foreground block text-[10px] uppercase font-bold">Endpoint</span>
                            <div className="bg-muted/50 p-2 rounded font-mono text-xs border border-border">
                                {selectedLog?.endpoint || '/'}
                            </div>
                        </div>

                        <div className="space-y-1">
                            <span className="text-muted-foreground block text-[10px] uppercase font-bold">Açıklama</span>
                            <p className="text-sm">
                                {selectedLog?.description || 'Açıklama belirtilmemiş.'}
                            </p>
                        </div>

                        <div className="space-y-1">
                            <span className="text-muted-foreground block text-[10px] uppercase font-bold">Veri (JSON Payload)</span>
                            <div className="bg-slate-950 text-slate-100 p-4 rounded-md font-mono text-xs overflow-x-auto whitespace-pre-wrap border border-slate-800 shadow-inner max-h-[300px] overflow-y-auto custom-scrollbar">
                                {selectedLog?.data ? (
                                    (() => {
                                        try {
                                            const parsed = JSON.parse(selectedLog.data);
                                            return JSON.stringify(parsed, null, 2);
                                        } catch (e) {
                                            return selectedLog.data;
                                        }
                                    })()
                                ) : (
                                    <span className="text-slate-500 italic">Gönderilen veri yok.</span>
                                )}
                            </div>
                        </div>
                    </div>

                    <DialogFooter>
                        <DialogClose asChild>
                            <Button variant="outline" className="w-full sm:w-auto">Kapat</Button>
                        </DialogClose>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
