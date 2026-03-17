"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { apiFetch } from "@/lib/apiFetch";
import dynamic from 'next/dynamic';
import { AnimatePresence } from 'framer-motion';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { format, differenceInDays } from "date-fns";
import { tr } from "date-fns/locale";

import { useDashboardWidgetsStore } from "@/store/dashboard-widgets";
import { WidgetWrapper } from "./components/WidgetWrapper";
import { Edit2, Check, PackagePlus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { MarketplaceSheet } from "@/components/dashboard/marketplace/marketplace-sheet";
import { cn } from "@/lib/utils";
import DailyGrowthWidget from "@/components/dashboard/widgets/daily-growth";
import WeeklyContentActivityWidget from "@/components/dashboard/widgets/weekly-content-activity";
import CategoryDistributionWidget from "@/components/dashboard/widgets/category-distribution";
import HealthCheckWidget from "@/components/dashboard/widgets/health-check";
import SpecialDaysCountdownWidget from "@/components/dashboard/widgets/special-days-countdown";
import ContentTypeTrendsWidget from "@/components/dashboard/widgets/content-type-trends";
import { DashboardGrid } from "./components/DashboardGrid";
import { SortableItem } from "./components/SortableItem";

const UserStatsChart = dynamic(() => import('./components/UserStatsChart'), {
    ssr: false,
    loading: () => <div className="w-full h-full min-h-[300px] bg-muted/20 animate-pulse rounded-lg"></div>
});

const ContentTypeDonut = dynamic(() => import('./components/ContentTypeDonut'), {
    ssr: false,
    loading: () => <div className="w-full h-full min-h-[180px] bg-muted/20 animate-pulse rounded-full"></div>
});

interface UserStats {
    monthly: { month: string; totalUsers: number; newUsers: number }[];
    activeUsers: number;
    passiveUsers: number;
    newUsersThisMonth: number;
}

interface ContentDistribution {
    ayet: number;
    hadis: number;
    dua: number;
    soz: number;
}

interface SpecialDayRatio {
    specialDayContents: number;
    normalContents: number;
}

interface UpcomingSpecialDay {
    id: string;
    title: string;
    date: string;
}

interface RecentContent {
    id: string;
    title: string;
    typeName: string;
    date: string;
    categories: string[];
}

interface DailyGrowth {
    todayCount: number;
    yesterdayCount: number;
    difference: number;
    trend: string;
}

interface WeeklyActivity {
    dates: string[];
    counts: number[];
}

interface CategoryCount {
    categoryName: string;
    count: number;
}

interface HealthCheck {
    uptimeHours: number;
    averageResponseTimeMs: number;
    errorCountLast24Hours: number;
    status: string;
}

interface SpecialDayCountdown {
    name: string;
    date: string;
    daysLeft: number;
}

interface ContentTypeTrend {
    type: string;
    last30Days: number[];
}

export default function DashboardPage() {
    const { widgets, editMode, setEditMode, fetchLayout, isLoading: isLayoutLoading } = useDashboardWidgetsStore();
    
    useEffect(() => {
        // Fetch layout from DB first
        fetchLayout();
    }, [fetchLayout]);

    const [userStats, setUserStats] = useState<UserStats | null>(null);
    const [contentTypeDist, setContentTypeDist] = useState<ContentDistribution | null>(null);
    const [specialDayRatio, setSpecialDayRatio] = useState<SpecialDayRatio | null>(null);
    const [upcomingDays, setUpcomingDays] = useState<UpcomingSpecialDay[]>([]);
    const [recentContents, setRecentContents] = useState<RecentContent[]>([]);

    const [loading, setLoading] = useState(true);
    const [marketplaceOpen, setMarketplaceOpen] = useState(false);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchDashboardData = async () => {
            try {
                setLoading(true);
                const [
                    statsData,
                    distData,
                    ratioData,
                    daysData,
                    contentsData
                ] = await Promise.all([
                    apiFetch<UserStats>("/dashboard/user-stats"),
                    apiFetch<ContentDistribution>("/dashboard/content-type-distribution"),
                    apiFetch<SpecialDayRatio>("/dashboard/specialday-content-ratio"),
                    apiFetch<UpcomingSpecialDay[]>("/dashboard/upcoming-special-days"),
                    apiFetch<RecentContent[]>("/dashboard/recent-contents")
                ]);

                setUserStats(statsData);
                setContentTypeDist(distData);
                setSpecialDayRatio(ratioData);
                setUpcomingDays(Array.isArray(daysData) ? daysData : []);
                setRecentContents(Array.isArray(contentsData) ? contentsData : []);
                setError(null);
            } catch (err: unknown) {
                console.error(err);
                setError("Veriler yüklenirken bir hata oluştu.");
            } finally {
                setLoading(false);
            }
        };

        fetchDashboardData();
    }, []);

    const COLORS = ['#3b82f6', '#10b981', '#a855f7', '#f97316'];

    if (loading) {
        return (
            <div className="space-y-6 animate-pulse">
                <div className="mb-6 lg:mb-10">
                    <div className="h-10 w-48 bg-muted rounded-md mb-2"></div>
                    <div className="h-4 w-72 bg-muted/60 rounded-md"></div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="rounded-2xl bg-card p-6 shadow-sm border border-border md:col-span-2 h-[400px]"></div>
                    <div className="rounded-2xl bg-card p-6 shadow-sm border border-border h-[280px]"></div>
                    <div className="rounded-2xl bg-card p-6 shadow-sm border border-border h-[280px]"></div>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="p-4 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 rounded-md border border-red-200 dark:border-red-800/30">
                {error}
            </div>
        );
    }

    const chartData = userStats?.monthly?.map(m => {
        const [year, month] = m.month.split('-');
        const dateObj = new Date(parseInt(year), parseInt(month) - 1, 1);
        return {
            name: format(dateObj, 'MMM yy', { locale: tr }),
            totalUsers: m.totalUsers,
            newUsers: m.newUsers
        };
    }) || [];

    const pieData = [
        { name: 'Ayet', value: contentTypeDist?.ayet || 0 },
        { name: 'Hadis', value: contentTypeDist?.hadis || 0 },
        { name: 'Dua', value: contentTypeDist?.dua || 0 },
        { name: 'Söz', value: contentTypeDist?.soz || 0 },
    ].filter(d => d.value > 0);

    const totalContent = pieData.reduce((acc, curr) => acc + curr.value, 0);

    const renderUserStats = () => (
        <WidgetWrapper key="userStats" id="userStats">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6">
                <h2 className="text-lg font-semibold">Kullanıcı İstatistikleri</h2>
                <div className="flex gap-4 mt-4 sm:mt-0">
                    <div className="text-center bg-gray-50 dark:bg-gray-800/50 px-3 py-2 rounded-lg border border-gray-100 dark:border-gray-800">
                        <p className="text-xs text-muted-foreground font-medium">Aktif</p>
                        <p className="text-lg font-bold text-green-600 dark:text-green-500">{userStats?.activeUsers || 0}</p>
                    </div>
                    <div className="text-center bg-gray-50 dark:bg-gray-800/50 px-3 py-2 rounded-lg border border-gray-100 dark:border-gray-800">
                        <p className="text-xs text-muted-foreground font-medium">Pasif</p>
                        <p className="text-lg font-bold text-gray-500">{userStats?.passiveUsers || 0}</p>
                    </div>
                    <div className="text-center bg-blue-50 dark:bg-blue-900/20 px-3 py-2 rounded-lg border border-blue-100 dark:border-blue-800/30">
                        <p className="text-xs text-blue-600 dark:text-blue-400 font-medium">Bu Ay Yeni</p>
                        <p className="text-lg font-bold text-blue-700 dark:text-blue-300">+{userStats?.newUsersThisMonth || 0}</p>
                    </div>
                </div>
            </div>
            <div className="flex-1 w-full min-h-[300px]">
                <UserStatsChart data={chartData} />
            </div>
        </WidgetWrapper>
    );

    const renderContentDist = () => (
        <WidgetWrapper key="contentDistribution" id="contentDistribution">
            <h2 className="text-lg font-semibold mb-2">İçerik Tipi Dağılımı</h2>
            <div className="relative flex-1 min-h-[180px] w-full flex items-center justify-center">
                {totalContent > 0 ? (
                    <>
                        <ContentTypeDonut pieData={pieData} colors={COLORS} />
                        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                            <span className="text-2xl font-bold">{totalContent}</span>
                            <span className="text-xs text-muted-foreground">Toplam</span>
                        </div>
                    </>
                ) : (
                    <div className="text-sm text-muted-foreground flex h-full items-center">İçerik bulunamadı.</div>
                )}
            </div>
            <div className="mt-2 flex flex-wrap justify-center gap-x-4 gap-y-2">
                {pieData.map((entry, index) => (
                    <div key={index} className="flex items-center gap-1.5">
                        <div className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: COLORS[index % COLORS.length] }} />
                        <span className="text-xs text-muted-foreground font-medium">{entry.name}: <span className="text-foreground">{entry.value}</span></span>
                    </div>
                ))}
            </div>
        </WidgetWrapper>
    );

    const renderCategoryBreakdown = () => (
        <WidgetWrapper key="specialDayContentRatio" id="specialDayContentRatio">
            <h2 className="text-lg font-semibold mb-4">Özel Gün İçerik Oranı</h2>
            <div className="space-y-4">
                <div className="flex justify-between items-center text-sm">
                    <span className="font-medium text-blue-600 dark:text-blue-400">Özel Gün: {specialDayRatio?.specialDayContents || 0}</span>
                    <span className="font-medium text-gray-600 dark:text-gray-400">Normal: {specialDayRatio?.normalContents || 0}</span>
                </div>
                <div className="w-full h-3 bg-gray-100 dark:bg-gray-800 rounded-full overflow-hidden flex">
                    {((specialDayRatio?.specialDayContents || 0) + (specialDayRatio?.normalContents || 0)) > 0 ? (
                        <>
                            <div
                                className="h-full bg-blue-500 transition-all duration-500"
                                style={{ width: `${((specialDayRatio?.specialDayContents || 0) / ((specialDayRatio?.specialDayContents || 0) + (specialDayRatio?.normalContents || 0))) * 100}%` }}
                            ></div>
                            <div
                                className="h-full bg-gray-300 dark:bg-gray-600 transition-all duration-500"
                                style={{ width: `${((specialDayRatio?.normalContents || 0) / ((specialDayRatio?.specialDayContents || 0) + (specialDayRatio?.normalContents || 0))) * 100}%` }}
                            ></div>
                        </>
                    ) : (
                        <div className="w-full h-full bg-gray-200 dark:bg-gray-800"></div>
                    )}
                </div>
                <Link href="/dashboard/daily-contents" className="block text-center text-sm font-medium text-primary hover:text-primary/80 transition-colors mt-2">
                    Tüm İçerikleri Gör &rarr;
                </Link>
            </div>
        </WidgetWrapper>
    );

    const renderSpecialDays = () => (
        <WidgetWrapper key="upcomingSpecialDays" id="upcomingSpecialDays" className="p-0">
            <div className="p-5 border-b border-border bg-slate-50/50 dark:bg-slate-900/50 -m-6 mb-0">
                <h2 className="text-lg font-semibold">Yaklaşan Özel Günler</h2>
            </div>
            <div className="flex-1 mt-6">
                {upcomingDays.length > 0 ? (
                    <ul className="divide-y divide-border -mx-6">
                        {upcomingDays.map(day => {
                            const dateObj = new Date(day.date);
                            const today = new Date();
                            today.setHours(0, 0, 0, 0);
                            const diff = differenceInDays(dateObj, today);

                            return (
                                <li key={day.id} className="px-6 py-4 flex justify-between items-center hover:bg-muted/30 transition-colors">
                                    <div>
                                        <p className="font-medium">{day.title}</p>
                                        <p className="text-xs text-muted-foreground mt-0.5">{format(dateObj, 'd MMMM yyyy, EEEE', { locale: tr })}</p>
                                    </div>
                                    <div className="text-right">
                                        {diff === 0 ? (
                                            <span className="inline-flex items-center px-2 py-1 rounded bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400 text-xs font-semibold">Bugün</span>
                                        ) : diff === 1 ? (
                                            <span className="inline-flex items-center px-2 py-1 rounded bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 text-xs font-semibold">Yarın</span>
                                        ) : (
                                            <span className="text-sm font-medium text-muted-foreground">{diff} gün kaldı</span>
                                        )}
                                    </div>
                                </li>
                            );
                        })}
                    </ul>
                ) : (
                    <div className="p-8 text-center text-muted-foreground text-sm">
                        Yakın zamanda (önümüzdeki 30 gün) özel gün bulunmuyor.
                    </div>
                )}
            </div>
        </WidgetWrapper>
    );

    const renderRecentContents = () => (
        <WidgetWrapper key="recentContents" id="recentContents">
            <div className="p-5 border-b border-border bg-slate-50/50 dark:bg-slate-900/50 flex justify-between items-center -m-6 mb-0">
                <h2 className="text-lg font-semibold">Son Eklenen İçerikler</h2>
                <Link href="/dashboard/daily-contents" className="text-sm font-medium text-primary hover:underline">
                    Tümünü Gör
                </Link>
            </div>
            <div className="overflow-x-auto mt-6 -mx-6 mb-[-24px]">
                <Table>
                    <TableHeader>
                        <TableRow className="bg-muted/10 hover:bg-muted/10 border-b border-border">
                            <TableHead className="px-6 py-3 font-medium">Başlık</TableHead>
                            <TableHead className="px-6 py-3 font-medium">Tip</TableHead>
                            <TableHead className="px-6 py-3 font-medium">Kategoriler</TableHead>
                            <TableHead className="px-6 py-3 font-medium text-right">Tarih</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {recentContents.length > 0 ? recentContents.map((content) => (
                            <TableRow key={content.id} className="hover:bg-muted/30 transition-colors border-b border-border last:border-0">
                                <TableCell className="px-6 py-3 font-medium max-w-[150px] truncate" title={content.title}>
                                    {content.title}
                                </TableCell>
                                <TableCell className="px-6 py-3">
                                    <span className="inline-flex items-center rounded-md bg-gray-100 dark:bg-gray-800 px-2.5 py-0.5 text-xs font-medium text-gray-800 dark:text-gray-300">
                                        {content.typeName}
                                    </span>
                                </TableCell>
                                <TableCell className="px-6 py-3">
                                    <div className="flex flex-wrap gap-1">
                                        {content.categories && content.categories.length > 0 ?
                                            content.categories.slice(0, 2).map((cat, idx) => (
                                                <span key={idx} className="text-[10px] bg-primary/10 text-primary px-1.5 py-0.5 rounded">
                                                    {cat}
                                                </span>
                                            ))
                                            : <span className="text-muted-foreground">-</span>}
                                        {(content.categories?.length || 0) > 2 && (
                                            <span className="text-[10px] bg-muted text-muted-foreground px-1.5 py-0.5 rounded">
                                                +{content.categories.length - 2}
                                            </span>
                                        )}
                                    </div>
                                </TableCell>
                                <TableCell className="px-6 py-3 text-right text-xs text-muted-foreground whitespace-nowrap">
                                    {content.date ? format(new Date(content.date), 'dd MMM yyyy', { locale: tr }) : '-'}
                                </TableCell>
                            </TableRow>
                        )) : (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8 text-muted-foreground italic">
                                    Henüz içerik bulunmuyor.
                                </TableCell>
                            </TableRow>
                        )}
                    </TableBody>
                </Table>
            </div>
        </WidgetWrapper>
    );

    const renderDailyGrowth = () => (
        <WidgetWrapper key="dailyGrowth" id="dailyGrowth">
            <DailyGrowthWidget />
        </WidgetWrapper>
    );

    const renderWeeklyActivity = () => (
        <WidgetWrapper key="weeklyContentActivity" id="weeklyContentActivity">
            <WeeklyContentActivityWidget />
        </WidgetWrapper>
    );

    const renderCategoryDistribution = () => (
        <WidgetWrapper key="categoryDistribution" id="categoryDistribution">
            <CategoryDistributionWidget />
        </WidgetWrapper>
    );

    const renderHealthCheck = () => (
        <WidgetWrapper key="healthCheck" id="healthCheck">
            <HealthCheckWidget />
        </WidgetWrapper>
    );

    const renderCountdown = () => (
        <WidgetWrapper key="specialDaysCountdown" id="specialDaysCountdown">
            <SpecialDaysCountdownWidget />
        </WidgetWrapper>
    );

    const renderTypeTrends = () => (
        <WidgetWrapper key="contentTypeTrends" id="contentTypeTrends">
            <ContentTypeTrendsWidget />
        </WidgetWrapper>
    );

    return (
        <div className="space-y-6">
            <MarketplaceSheet open={marketplaceOpen} onOpenChange={setMarketplaceOpen} />

            {/* Header with Edit Toggle */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 lg:mb-10 gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight text-slate-800 dark:text-white">Dashboard</h1>
                    <p className="text-muted-foreground mt-2">Uygulamanın genel istatistikleri ve güncel durumu</p>
                </div>
                <div className="flex items-center gap-3">
                    {editMode && (
                        <Button
                            variant="outline"
                            onClick={() => setMarketplaceOpen(true)}
                            className="gap-2 shadow-sm border-dashed border-primary/50 hover:border-primary text-primary"
                        >
                            <PackagePlus className="w-4 h-4" /> Widget Ekle
                        </Button>
                    )}
                    <Button
                        variant={editMode ? "default" : "outline"}
                        onClick={() => setEditMode(!editMode)}
                        className="gap-2 shrink-0 shadow-sm"
                    >
                        {editMode ? (
                            <><Check className="w-4 h-4" /> Düzenlemeyi Bitir</>
                        ) : (
                            <><Edit2 className="w-4 h-4" /> Düzenle</>
                        )}
                    </Button>
                </div>
            </div>

            {/* Grid */}
            <DashboardGrid>
                <AnimatePresence mode="popLayout" initial={false}>
                    {widgets
                        .filter(w => w.added)
                        .slice()
                        .sort((a, b) => a.order - b.order)
                        .map((w) => {
                            if (!editMode && !w.visible) return null;

                            return (
                                <SortableItem key={w.id} id={w.id} disabled={!editMode}>
                                    {(() => {
                                        switch (w.id) {
                                            case "userStats": return renderUserStats();
                                            case "contentDistribution": return renderContentDist();
                                            case "dailyGrowth": return renderDailyGrowth();
                                            case "weeklyContentActivity": return renderWeeklyActivity();
                                            case "categoryDistribution": return renderCategoryDistribution();
                                            case "healthCheck": return renderHealthCheck();
                                            case "specialDaysCountdown": return renderCountdown();
                                            case "contentTypeTrends": return renderTypeTrends();
                                            case "upcomingSpecialDays": return renderSpecialDays();
                                            case "recentContents": return renderRecentContents();
                                            case "specialDayContentRatio": return renderCategoryBreakdown();
                                            default: return null;
                                        }
                                    })()}
                                </SortableItem>
                            );
                        })}
                </AnimatePresence>
            </DashboardGrid>
        </div>
    );
}
