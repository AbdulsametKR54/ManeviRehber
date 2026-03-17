"use client";

import React from "react";
import Link from "next/link";
import { Menu, Bell } from "lucide-react";
import { useAuthStore } from "@/lib/auth";
import { ModeToggle } from "@/components/ModeToggle";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useDashboardLayoutStore } from "./store";

export const MazerNavbar = () => {
    const { toggleSidebar } = useDashboardLayoutStore();
    const { user, logout } = useAuthStore();

    return (
        <header className="flex h-[90px] items-center justify-between bg-background px-8 shadow-sm border-b border-border transition-all duration-300">
            {/* Left side: Hamburger */}
            <div className="flex items-center gap-4">
                <button
                    onClick={toggleSidebar}
                    className="rounded-lg p-2 text-muted-foreground hover:bg-accent/10 hover:text-foreground transition-colors"
                >
                    <Menu className="h-6 w-6" />
                </button>
            </div>

            {/* Right side: Actions */}
            <div className="flex items-center gap-6">
                <ModeToggle />
                {/* Notifications */}
                <button className="relative rounded-lg p-2 text-muted-foreground hover:bg-accent/10 hover:text-foreground transition-colors">
                    <Bell className="h-6 w-6" />
                    <span className="absolute right-2 top-2 flex h-2.5 w-2.5">
                        <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-red-400 opacity-75"></span>
                        <span className="relative inline-flex h-2.5 w-2.5 rounded-full bg-red-500"></span>
                    </span>
                </button>

                {/* Profile Dropdown */}
                <DropdownMenu>
                    <DropdownMenuTrigger className="flex items-center gap-3 outline-none">
                        <div className="flex flex-col items-end">
                            <span className="text-sm font-semibold text-foreground">
                                {user?.name || "Admin User"}
                            </span>
                            <span className="text-xs text-muted-foreground">Administrator</span>
                        </div>
                        <div className="h-10 w-10 overflow-hidden rounded-full bg-muted ring-2 ring-background">
                            <img
                                src="https://github.com/shadcn.png"
                                alt="Profile"
                                className="h-full w-full object-cover"
                            />
                        </div>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="w-56">
                        <DropdownMenuLabel>My Account</DropdownMenuLabel>
                        <DropdownMenuSeparator />
                        <Link href="/dashboard/profile">
                            <DropdownMenuItem className="cursor-pointer">Profilim</DropdownMenuItem>
                        </Link>
                        <Link href="/dashboard/settings">
                            <DropdownMenuItem className="cursor-pointer">Ayarlar</DropdownMenuItem>
                        </Link>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem
                            className="text-red-600 focus:bg-red-50 focus:text-red-600 dark:focus:bg-red-950"
                            onClick={() => logout()}
                        >
                            Log out
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            </div>
        </header>
    );
};
