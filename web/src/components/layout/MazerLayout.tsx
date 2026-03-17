"use client";

import React, { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/lib/auth";
import { MazerSidebar } from "./MazerSidebar";
import { MazerNavbar } from "./MazerNavbar";
import { useDashboardLayoutStore } from "./store";
import { cn } from "@/lib/utils";

export const MazerLayout = ({ children }: { children: React.ReactNode }) => {
    const router = useRouter();
    const token = useAuthStore((state) => state.token);
    const [isMounted, setIsMounted] = useState(false);
    const { isSidebarOpen } = useDashboardLayoutStore();

    const user = useAuthStore((state) => state.user);

    useEffect(() => {
        setIsMounted(true);
        if (!token) {
            router.push("/login");
            return;
        }

        if (user && user.role !== "Admin" && user.role !== "Editor") {
            useAuthStore.getState().logout();
            router.push("/login");
        }
    }, [token, user, router]);

    if (!isMounted || !token || (user && user.role !== "Admin" && user.role !== "Editor")) {
        return null; // Prevents hydration mismatch and flash of unauthenticated content
    }

    return (
        <div className="flex h-screen w-full overflow-hidden bg-background text-foreground transition-colors duration-300">
            <MazerSidebar />
            <div
                className={cn(
                    "flex flex-1 flex-col transition-all duration-300 ease-in-out",
                    // On large screens, adjust margin based on sidebar state. On mobile, no margin.
                    "lg:ml-[90px]",
                    isSidebarOpen && "lg:ml-[260px]"
                )}
            >
                <MazerNavbar />
                <main className="flex-1 overflow-auto p-8 lg:p-12">
                    <div className="mx-auto max-w-[1440px]">
                        {children}
                    </div>
                </main>
            </div>
        </div>
    );
};
