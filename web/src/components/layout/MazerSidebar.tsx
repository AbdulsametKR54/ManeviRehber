"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import { useDashboardLayoutStore } from "./store";
import { useAuthStore } from "@/lib/auth";

import {
    HomeIcon,
    UsersIcon,
    CategoryIcon,
    DocumentIcon,
    CalendarIcon,
    SettingIcon,
    TimeCircleIcon,
    InfoSquareIcon,
} from "@/icons/iconly";

const routes = [
    {
        category: "Menu",
        items: [
            {
                title: "Dashboard",
                href: "/dashboard",
                icon: HomeIcon,
            },
        ],
    },
    {
        category: "Content",
        items: [
            {
                title: "Users",
                href: "/dashboard/users",
                icon: UsersIcon,
            },
            {
                title: "Categories",
                href: "/dashboard/categories",
                icon: CategoryIcon,
            },
            {
                title: "Daily Contents",
                href: "/dashboard/daily-contents",
                icon: DocumentIcon,
            },
            {
                title: "Special Days",
                href: "/dashboard/special-days",
                icon: CalendarIcon,
            },
        ],
    },
    {
        category: "System",
        items: [
            {
                title: "Settings",
                href: "/dashboard/settings",
                icon: SettingIcon,
            },
            {
                title: "Prayer Times",
                href: "/dashboard/prayer-times",
                icon: TimeCircleIcon,
            },
            {
                title: "Logs",
                href: "/dashboard/logs",
                icon: InfoSquareIcon,
            },
            {
                title: "Notifications",
                href: "/dashboard/notifications",
                icon: InfoSquareIcon, // Temporary fallback until I confirm existence of NotificationIcon
            },
        ],
    },
    {
        category: "Kur'an Araçları",
        items: [
            {
                title: "Kur'an Test Paneli",
                href: "/dashboard/quran-test",
                icon: DocumentIcon,
            },
        ],
    },
];

export const MazerSidebar = () => {
    const pathname = usePathname();
    const { isSidebarOpen, setSidebarOpen } = useDashboardLayoutStore();
    const [isMobile, setIsMobile] = useState(false);

    // Auth Store'dan kullanıcı bilgisini hook ile alıyoruz
    const user = useAuthStore(state => state.user);

    const [filteredRoutes, setFilteredRoutes] = useState(routes);

    useEffect(() => {
        const userRole = user?.role;

        let allowedRoutes = routes;
        if (userRole === "Editor") {
            allowedRoutes = routes.map(group => {
                if (group.category === "System") return null;
                if (group.category === "Content") {
                    return {
                        ...group,
                        items: group.items.filter(item => ["Categories", "Daily Contents", "Special Days"].includes(item.title))
                    };
                }
                return group;
            }).filter(Boolean) as typeof routes;
        } else if (userRole !== "Admin") {
            allowedRoutes = [];
        }

        setFilteredRoutes(allowedRoutes);
    }, [user]);

    useEffect(() => {
        const checkMobile = () => {
            setIsMobile(window.innerWidth < 1024);
            if (window.innerWidth < 1024) {
                setSidebarOpen(false);
            } else {
                setSidebarOpen(true);
            }
        };

        checkMobile();
        window.addEventListener("resize", checkMobile);
        return () => window.removeEventListener("resize", checkMobile);
    }, [setSidebarOpen]);

    const closeOnMobile = () => {
        if (isMobile) {
            setSidebarOpen(false);
        }
    };

    return (
        <>
            {/* Mobile Backdrop */}
            {isSidebarOpen && isMobile && (
                <div
                    className="fixed inset-0 z-40 bg-black/50 lg:hidden transition-opacity"
                    onClick={() => setSidebarOpen(false)}
                />
            )}

            {/* Sidebar Container */}
            <aside
                className={cn(
                    "fixed inset-y-0 left-0 z-50 flex flex-col bg-card shadow-lg transition-all duration-300 ease-in-out border-r border-border",
                    isSidebarOpen ? "w-[260px] translate-x-0" : isMobile ? "-translate-x-full w-[260px]" : "w-[90px] translate-x-0"
                )}
            >
                {/* Logo/Header */}
                <div className={cn(
                    "flex h-[90px] items-center text-primary",
                    isSidebarOpen ? "px-8" : "justify-center px-4"
                )}>
                    {isSidebarOpen ? (
                        <div className="text-2xl font-black tracking-tighter">
                            Manevi <span className="text-slate-400 dark:text-slate-500">REHBER</span>
                        </div>
                    ) : (
                        <div className="text-2xl font-black">MR</div>
                    )}
                </div>

                {/* Navigation Menu */}
                <div className={cn("flex-1 overflow-y-auto overflow-x-hidden p-4", isSidebarOpen ? "pe-4" : "px-3")}>
                    <ul className="flex flex-col gap-2">
                        {filteredRoutes.map((group, groupIndex) => (
                            <li key={groupIndex} className="mt-4 first:mt-0">
                                {isSidebarOpen ? (
                                    <h6 className="px-4 text-xs font-semibold text-[#8094ae] uppercase mb-2">
                                        {group.category}
                                    </h6>
                                ) : (
                                    <div className="h-4" /> // spacer
                                )}

                                <ul className="flex flex-col gap-1">
                                    {group.items.map((item, itemIndex) => {
                                        const isActive = pathname === item.href || (pathname.startsWith(item.href) && item.href !== "/dashboard");

                                        return (
                                            <li key={itemIndex} className="relative group/menuitem">
                                                <Link
                                                    href={item.href}
                                                    onClick={closeOnMobile}
                                                    className={cn(
                                                        "flex items-center rounded-lg py-3 transition-colors",
                                                        isSidebarOpen ? "px-4" : "justify-center px-0",
                                                        isActive
                                                            ? "bg-primary/20 text-primary font-semibold shadow-sm"
                                                            : "text-muted-foreground hover:bg-accent/10 hover:text-primary"
                                                    )}
                                                >
                                                    <item.icon className={cn("shrink-0", isActive ? "text-primary-foreground" : "text-muted-foreground group-hover/menuitem:text-primary", isSidebarOpen ? "w-5 h-5 mr-4" : "w-6 h-6")} />
                                                    {isSidebarOpen && <span className="text-[15px]">{item.title}</span>}
                                                </Link>

                                                {/* Tooltip for narrow mode */}
                                                {!isSidebarOpen && !isMobile && (
                                                    <div className="pointer-events-none absolute left-full top-1/2 z-50 ml-3 -translate-y-1/2 translate-x-2 whitespace-nowrap rounded-md bg-slate-800 px-3 py-1.5 text-sm font-medium text-white opacity-0 transition-all duration-300 delay-200 group-hover/menuitem:translate-x-0 group-hover/menuitem:opacity-100 dark:bg-slate-50 dark:text-slate-900 shadow-md">
                                                        {item.title}
                                                        {/* Arrow */}
                                                        <div className="absolute -left-1 top-1/2 -mt-1 h-2 w-2 -translate-y-1/2 rotate-45 bg-slate-800 dark:bg-slate-50" />
                                                    </div>
                                                )}
                                            </li>
                                        );
                                    })}
                                </ul>
                            </li>
                        ))}
                    </ul>
                </div>
            </aside>
        </>
    );
};
