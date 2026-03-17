"use client";

import { useState, useEffect } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { apiUsers } from "@/lib/api";
import { useAuthStore } from "@/lib/auth";
import { toast } from "sonner";

interface UpdateRoleDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    user: any | null;
    onSuccess: () => void;
}

export function UpdateRoleDialog({ open, onOpenChange, user, onSuccess }: UpdateRoleDialogProps) {
    const { user: currentUser } = useAuthStore();
    const [loading, setLoading] = useState(false);
    const [role, setRole] = useState("User");

    const isSelf = currentUser?.id === user?.id;

    useEffect(() => {
        if (user) {
            setRole(user.role || "User");
        }
    }, [user]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!user) return;
        try {
            setLoading(true);
            await apiUsers.updateRole(user.id, role);
            toast.success("Kullanıcı rolü başarıyla güncellendi.");
            onSuccess();
            onOpenChange(false);
        } catch (error: any) {
            toast.error(error.response?.data?.message || "Rol güncellenirken bir hata oluştu.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="sm:max-w-[425px]">
                <DialogHeader>
                    <DialogTitle>Kullanıcı Rolünü Düzenle</DialogTitle>
                </DialogHeader>
                <form onSubmit={handleSubmit} className="space-y-4 pt-4">
                    <div className="space-y-2">
                        <Label>Seçili Kullanıcı: {user?.name}</Label>
                    </div>
                    <div className="space-y-2">
                        <Label>Yeni Rol</Label>
                        <Select
                            value={role}
                            onValueChange={setRole}
                            disabled={isSelf}
                        >
                            <SelectTrigger>
                                <SelectValue placeholder="Rol seçin" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="User">User</SelectItem>
                                <SelectItem value="Editor">Editor</SelectItem>
                                <SelectItem value="Admin">Admin</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                    <DialogFooter className="pt-4">
                        <Button type="button" variant="outline" onClick={() => onOpenChange(false)} disabled={loading}>
                            İptal
                        </Button>
                        <Button type="submit" disabled={loading}>
                            {loading ? "Güncelleniyor..." : "Güncelle"}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
