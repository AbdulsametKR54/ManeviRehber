"use client";

import { MazerLayout } from "@/components/layout/MazerLayout";

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return <MazerLayout>{children}</MazerLayout>;
}
