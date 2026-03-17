"use client";

import { useState } from "react";
import { format } from "date-fns";
import { tr } from "date-fns/locale";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Trash2 } from "lucide-react";
import { apiUsers } from "@/lib/api";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { Shield, Ban, CheckCircle } from "lucide-react";
import { UpdateRoleDialog } from "./UpdateRoleDialog";

interface UserTableProps {
    users: any[];
    loading: boolean;
    onRefresh: () => void;
    page: number;
    pageSize: number;
    totalCount: number;
    onPageChange: (page: number) => void;
}

export function UserTable({ users, loading, onRefresh, page, pageSize, totalCount, onPageChange }: UserTableProps) {
    const [userToDelete, setUserToDelete] = useState<string | null>(null);
    const [isDeleting, setIsDeleting] = useState(false);
    const [userToUpdateRole, setUserToUpdateRole] = useState<any | null>(null);

    const handleDeleteConfirm = async () => {
        if (!userToDelete) return;

        try {
            setIsDeleting(true);
            await apiUsers.delete(userToDelete);
            onRefresh();
        } catch (error) {
            console.error("Failed to delete user", error);
        } finally {
            setIsDeleting(false);
            setUserToDelete(null);
        }
    };

    const handleToggleActive = async (user: any) => {
        try {
            if (user.isActive) {
                await apiUsers.deactivate(user.id);
            } else {
                await apiUsers.activate(user.id);
            }
            onRefresh();
        } catch (error) {
            console.error("Failed to change user status", error);
        }
    };

    const totalPages = Math.ceil(totalCount / pageSize);

    if (loading) {
        return <div className="p-8 text-center text-muted-foreground animate-pulse">Kullanıcılar yükleniyor...</div>;
    }

    if (users.length === 0) {
        return <div className="p-8 text-center text-muted-foreground">Kayıtlı kullanıcı bulunamadı.</div>;
    }

    return (
        <>
            <table className="w-full border-separate border-spacing-0 text-sm">
                <thead>
                    <tr>
                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İsim</th>
                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Email</th>
                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Dil</th>
                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Kayıt Tarihi</th>
                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Rol</th>
                        <th className="bg-gray-50 dark:bg-gray-800 text-left px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">Durum</th>
                        <th className="bg-gray-50 dark:bg-gray-800 text-right px-4 py-3 font-medium border-b border-gray-200 dark:border-gray-700">İşlemler</th>
                    </tr>
                </thead>
                <tbody>
                    {users.map((user, i) => (
                        <tr
                            key={user.id}
                            className={`
                                ${i % 2 === 0 ? "bg-white dark:bg-gray-900" : "bg-gray-50 dark:bg-gray-800"}
                                hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors
                            `}
                        >
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 font-semibold">{user.name}</td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 text-muted-foreground">{user.email}</td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                <span className="inline-flex items-center rounded-md bg-gray-100 dark:bg-gray-700 px-2 py-1 text-xs font-medium text-gray-700 dark:text-gray-200">
                                    {user.language || 'TR'}
                                </span>
                            </td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700 text-muted-foreground">
                                {user.createdAt ? format(new Date(user.createdAt), 'dd MMM yyyy', { locale: tr }) : '-'}
                            </td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                <span className="inline-flex items-center rounded-md bg-gray-100 dark:bg-gray-700 px-2 py-1 text-xs font-medium text-gray-700 dark:text-gray-200">
                                    {user.role || 'User'}
                                </span>
                            </td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                {user.isActive ? (
                                    <span className="inline-flex items-center rounded-md bg-green-100 dark:bg-green-900 px-2 py-1 text-xs font-medium text-green-700 dark:text-green-200">
                                        Aktif
                                    </span>
                                ) : (
                                    <span className="inline-flex items-center rounded-md bg-red-100 dark:bg-red-900 px-2 py-1 text-xs font-medium text-red-700 dark:text-red-200">
                                        Pasif
                                    </span>
                                )}
                            </td>
                            <td className="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                                <div className="flex items-center justify-end gap-3 h-full min-h-[40px]">
                                    <button
                                        className="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300 transition-colors"
                                        onClick={() => setUserToUpdateRole(user)}
                                        title="Rol Değiştir"
                                    >
                                        <Shield className="h-4 w-4" />
                                    </button>
                                    <button
                                        className="text-amber-500 hover:text-amber-600 dark:text-amber-400 dark:hover:text-amber-300 transition-colors"
                                        onClick={() => handleToggleActive(user)}
                                        title={user.isActive ? "Pasife Al" : "Aktifleştir"}
                                    >
                                        {user.isActive ? <Ban className="h-4 w-4" /> : <CheckCircle className="h-4 w-4" />}
                                    </button>
                                    <button
                                        className="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 transition-colors"
                                        onClick={() => setUserToDelete(user.id)}
                                        title="Sil"
                                    >
                                        <Trash2 className="h-4 w-4" />
                                    </button>
                                </div>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>

            <div className="mt-4 flex items-center justify-between">
                <span className="text-sm text-muted-foreground">Toplam {totalCount} kayıt, Sayfa {page} / {totalPages || 1}</span>
                <div className="flex gap-2">
                    <Button variant="outline" size="sm" onClick={() => onPageChange(Math.max(1, page - 1))} disabled={page <= 1} className="h-8">Önceki</Button>
                    <Button variant="outline" size="sm" onClick={() => onPageChange(Math.min(totalPages, page + 1))} disabled={page >= totalPages} className="h-8">Sonraki</Button>
                </div>
            </div>

            <Dialog open={!!userToDelete} onOpenChange={(open: boolean) => !open && setUserToDelete(null)}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Kullanıcıyı Sil</DialogTitle>
                        <DialogDescription>
                            Bu kullanıcıyı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.
                        </DialogDescription>
                    </DialogHeader>
                    <DialogFooter className="mt-4">
                        <Button
                            variant="outline"
                            onClick={() => setUserToDelete(null)}
                            disabled={isDeleting}
                        >
                            İptal
                        </Button>
                        <Button
                            variant="destructive"
                            onClick={handleDeleteConfirm}
                            disabled={isDeleting}
                        >
                            {isDeleting ? "Siliniyor..." : "Evet, Sil"}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <UpdateRoleDialog
                open={!!userToUpdateRole}
                onOpenChange={(open) => !open && setUserToUpdateRole(null)}
                user={userToUpdateRole}
                onSuccess={onRefresh}
            />
        </>
    );
}
