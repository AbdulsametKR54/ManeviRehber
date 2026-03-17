"use client";

import { useEffect, useState } from "react";
import { apiUsers } from "@/lib/api";
import { UserTable } from "./components/UserTable";
import { CreateUserDialog } from "./components/CreateUserDialog";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export default function UsersPage() {
    const [users, setUsers] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [createOpen, setCreateOpen] = useState(false);

    // Pagination state
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(10);
    const [totalCount, setTotalCount] = useState(0);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            const res = await apiUsers.getAll(page, pageSize);
            if (res.data?.items) {
                setUsers(res.data.items);
                setTotalCount(res.data.totalCount);
            } else {
                setUsers(res.data || []);
            }
        } catch (error) {
            console.error("Failed to fetch users", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchUsers();
    }, [page, pageSize]);

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Kullanıcı Yönetimi</h1>
                    <p className="text-muted-foreground">Sistemdeki tüm kullanıcıları görüntüleyin ve yönetin.</p>
                </div>
                <Button onClick={() => setCreateOpen(true)} className="bg-primary text-primary-foreground hover:bg-primary/90">
                    Yeni Kullanıcı Ekle
                </Button>
            </div>

            <CreateUserDialog
                open={createOpen}
                onOpenChange={setCreateOpen}
                onSuccess={fetchUsers}
            />

            <div className="rounded-lg border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 shadow-sm p-6 mt-6">
                <h2 className="text-xl font-semibold mb-6">Kullanıcı Listesi</h2>
                <div className="mt-4">
                    <UserTable
                        users={users}
                        loading={loading}
                        onRefresh={fetchUsers}
                        page={page}
                        pageSize={pageSize}
                        totalCount={totalCount}
                        onPageChange={setPage}
                    />
                </div>
            </div>
        </div>
    );
}
