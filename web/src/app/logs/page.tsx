"use client";

import { useEffect, useState } from "react";
import apiClient from "@/lib/axios";
import { LogDto } from "@/types/dto";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";

export default function LogsPage() {
    const [logs, setLogs] = useState<LogDto[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchLogs = async () => {
        try {
            const { data } = await apiClient.get<LogDto[]>("/Logs");
            setLogs(data);
        } catch (error) {
            console.error("Loglar getirilemedi:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchLogs();
    }, []);

    return (
        <div className="p-8 space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Sistem Logları</h1>
            </div>

            <div className="border rounded-md bg-white dark:bg-zinc-900 border-zinc-200 dark:border-zinc-800">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>İşlem</TableHead>
                            <TableHead>Açıklama</TableHead>
                            <TableHead>IP Adresi</TableHead>
                            <TableHead>Tarih</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8">
                                    Yükleniyor...
                                </TableCell>
                            </TableRow>
                        ) : logs.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8 text-zinc-500">
                                    Kayıt bulunamadı.
                                </TableCell>
                            </TableRow>
                        ) : (
                            logs.map((item) => (
                                <TableRow key={item.id}>
                                    <TableCell className="font-medium">{item.action}</TableCell>
                                    <TableCell>{item.description}</TableCell>
                                    <TableCell>{item.ipAddress}</TableCell>
                                    <TableCell>{new Date(item.createdAt).toLocaleString("tr-TR")}</TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
