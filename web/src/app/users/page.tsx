"use client";

import { useEffect, useState } from "react";
import apiClient from "@/lib/axios";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";

interface UserResponse {
    id: string;
    name: string;
    email: string;
    language: string;
    createdAt: string;
}

export default function UsersPage() {
    const [users, setUsers] = useState<UserResponse[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchUsers();
    }, []);

    const fetchUsers = async () => {
        try {
            const { data } = await apiClient.get<UserResponse[]>("/Users");
            setUsers(data);
        } catch (error) {
            console.error("Kullanıcılar getirilemedi:", error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="p-8 space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Kullanıcılar</h1>
            </div>

            <div className="border rounded-md bg-white dark:bg-zinc-900 border-zinc-200 dark:border-zinc-800">
                <Table>
                    <TableHeader>
                        <TableRow>
                            <TableHead>Adı</TableHead>
                            <TableHead>E-Posta</TableHead>
                            <TableHead>Dil</TableHead>
                            <TableHead>Oluşturulma Tarihi</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {loading ? (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8">
                                    Yükleniyor...
                                </TableCell>
                            </TableRow>
                        ) : users.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8 text-zinc-500">
                                    Kullanıcı bulunamadı.
                                </TableCell>
                            </TableRow>
                        ) : (
                            users.map((user) => (
                                <TableRow key={user.id}>
                                    <TableCell className="font-medium">{user.name}</TableCell>
                                    <TableCell>{user.email}</TableCell>
                                    <TableCell>{user.language}</TableCell>
                                    <TableCell>{new Date(user.createdAt).toLocaleDateString("tr-TR")}</TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>
        </div>
    );
}
