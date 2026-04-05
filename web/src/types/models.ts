import { ContentType, Language } from "./enums";

export interface PagedResponse<T> {
    items: T[];
    totalCount: number;
    page: number;
    pageSize: number;
}

export interface Category {
    id: string;
    name: string;
    description?: string;
}

export interface DailyContent {
    id: string;
    title: string;
    content: string;
    type: ContentType;
    date: string;
    categoryId?: undefined; // Removed
    categoryName?: undefined; // Removed
    specialDayId?: string | null;
    specialDayName?: string | null;
    categories?: { id: string; name: string }[];
}

export interface Log {
    id: string;
    userId: string;
    action: string;
    description: string;
    data: string;
    ipAddress: string;
}

export interface PrayerTime {
    id: string;
    locationId: number;
    date: string;
    fajr: string;
    sunrise: string;
    dhuhr: string;
    asr: string;
    maghrib: string;
    sunset: string;
    isha: string;
    hijriDateLong: string;
}

export interface Setting {
    id: string;
    key: string;
    value: string;
    description?: string;
}

export interface SpecialDay {
    id: string;
    name: string;
    date: string;
    description: string;
}

export interface User {
    id: string;
    name: string;
    email: string;
    language: Language | string;
    role: string;
    isActive: boolean;
    createdAt: string;
}
