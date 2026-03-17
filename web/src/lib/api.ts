import { apiFetch } from './apiFetch';

// Helper to wrap apiFetch result back into axios-like { data: ... } structure for backward compatibility
const fetchWrap = async <T>(endpoint: string, options?: RequestInit) => {
    const data = await apiFetch<T>(endpoint, options);
    return { data };
};

// Users API
export const apiUsers = {
    getAll: (page: number = 1, pageSize: number = 10) => fetchWrap(`/users?page=${page}&pageSize=${pageSize}`),
    getById: (id: string) => fetchWrap(`/users/${id}`),
    create: (data: unknown) => fetchWrap('/users', { method: 'POST', body: JSON.stringify(data) }),
    updateName: (id: string, data: unknown) => fetchWrap(`/users/${id}/name`, { method: 'PUT', body: JSON.stringify(data) }),
    updateEmail: (id: string, data: unknown) => fetchWrap(`/users/${id}/email`, { method: 'PUT', body: JSON.stringify(data) }),
    updateLanguage: (id: string, data: unknown) => fetchWrap(`/users/${id}/language`, { method: 'PUT', body: JSON.stringify(data) }),
    updateRole: (id: string, role: string) => fetchWrap(`/users/${id}/role`, { method: 'PUT', body: JSON.stringify({ role }) }),
    updateProfile: (data: unknown) => fetchWrap(`/users/me`, { method: 'PUT', body: JSON.stringify(data) }),
    delete: (id: string) => fetchWrap(`/users/${id}`, { method: 'DELETE' }),
    deactivate: (id: string) => fetchWrap(`/users/${id}/deactivate`, { method: 'PATCH' }),
    activate: (id: string) => fetchWrap(`/users/${id}/activate`, { method: 'PATCH' }),
    ban: (id: string) => fetchWrap(`/users/${id}/ban`, { method: 'PUT' }),
    unban: (id: string) => fetchWrap(`/users/${id}/unban`, { method: 'PUT' }),
};

// Category API
export const apiCategory = {
    getAll: () => fetchWrap('/category'),
    getPaged: (search: string = "", page: number = 1, pageSize: number = 10) => 
        fetchWrap(`/category/paged?search=${encodeURIComponent(search)}&page=${page}&pageSize=${pageSize}`),
    getById: (id: string) => fetchWrap(`/category/${id}`),
    create: (data: unknown) => fetchWrap('/category', { method: 'POST', body: JSON.stringify(data) }),
    update: (id: string, data: unknown) => fetchWrap(`/category/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
    delete: (id: string) => fetchWrap(`/category/${id}`, { method: 'DELETE' }),
};

// DailyContent API
export const apiDailyContent = {
    getAll: (categoryId?: string, specialDayId?: string) => {
        const queryParams = new URLSearchParams();
        if (categoryId) queryParams.append('categoryId', categoryId);
        if (specialDayId) queryParams.append('specialDayId', specialDayId);
        const qs = queryParams.toString();
        return fetchWrap(`/dailycontents${qs ? `?${qs}` : ''}`);
    },
    getPagedDailyContents: (params: {
        search?: string;
        date?: string;
        type?: number | "";
        categoryId?: string;
        specialDayId?: string;
        page: number;
        pageSize: number;
    }) => {
        const queryParams = new URLSearchParams();
        if (params.search) queryParams.append('search', params.search);
        if (params.date) queryParams.append('date', params.date);
        if (params.type !== undefined && params.type !== null && params.type !== "") queryParams.append('type', params.type.toString());
        if (params.categoryId) queryParams.append('categoryId', params.categoryId);
        if (params.specialDayId) queryParams.append('specialDayId', params.specialDayId);
        queryParams.append('page', params.page.toString());
        queryParams.append('pageSize', params.pageSize.toString());
        return fetchWrap(`/dailycontents/paged?${queryParams.toString()}`);
    },
    getById: (id: string) => fetchWrap(`/dailycontents/${id}`),
    create: (data: unknown) => fetchWrap('/dailycontents', { method: 'POST', body: JSON.stringify(data) }),
    update: (id: string, data: unknown) => fetchWrap(`/dailycontents/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
    delete: (id: string) => fetchWrap(`/dailycontents/${id}`, { method: 'DELETE' }),
};

// SpecialDay API
export const apiSpecialDay = {
    getAll: () => fetchWrap('/specialdays'),
    getPagedSpecialDays: (search: string = "", page: number = 1, pageSize: number = 10) => 
        fetchWrap(`/specialdays/paged?search=${encodeURIComponent(search)}&page=${page}&pageSize=${pageSize}`),
    getById: (id: string) => fetchWrap(`/specialdays/${id}`),
    create: (data: unknown) => fetchWrap('/specialdays', { method: 'POST', body: JSON.stringify(data) }),
    update: (id: string, data: unknown) => fetchWrap(`/specialdays/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
    delete: (id: string) => fetchWrap(`/specialdays/${id}`, { method: 'DELETE' }),
};

// Settings API
export const apiSettings = {
    getAll: () => fetchWrap('/settings'),
    getById: (id: string) => fetchWrap(`/settings/${id}`),
    create: (data: unknown) => fetchWrap('/settings', { method: 'POST', body: JSON.stringify(data) }),
    update: (id: string, data: unknown) => fetchWrap(`/settings/${id}`, { method: 'PUT', body: JSON.stringify(data) }),
    delete: (id: string) => fetchWrap(`/settings/${id}`, { method: 'DELETE' }),
};

// PrayerTimes API
export const apiPrayerTimes = {
    getAll: (locationId?: number, date?: string) => {
        let query = '/prayertimes?';
        if (locationId) query += `locationId=${locationId}&`;
        if (date) query += `date=${date}`;
        return fetchWrap(query);
    },
    getMonthly: (locationId: number, year: number, month: number) =>
        fetchWrap(`/prayertimes/monthly?locationId=${locationId}&year=${year}&month=${month}`),
    sync: (locationId: number) => fetchWrap(`/prayertimes/sync/${locationId}`, { method: 'POST' }),
};

// Logs API
export const apiLogs = {
    getAll: (params?: Record<string, unknown>) => {
        const queryParams = new URLSearchParams();
        if (params) {
            Object.keys(params).forEach(key => {
                if (params[key] !== undefined && params[key] !== null) {
                    queryParams.append(key, String(params[key]));
                }
            });
        }
        const qs = queryParams.toString();
        return fetchWrap(`/logs${qs ? `?${qs}` : ''}`);
    }
};

// Auth API
export const apiAuth = {
    login: (data: unknown) => fetchWrap('/auth/login', { method: 'POST', body: JSON.stringify(data) }),
    register: (data: unknown) => fetchWrap('/auth/register', { method: 'POST', body: JSON.stringify(data) }),
    updateName: (data: { name: string }) => fetchWrap('/auth/update-name', { method: 'PUT', body: JSON.stringify(data) }),
    updateEmail: (data: { email: string }) => fetchWrap('/auth/update-email', { method: 'PUT', body: JSON.stringify(data) }),
    updateLanguage: (data: { language: string }) => fetchWrap('/auth/update-language', { method: 'PUT', body: JSON.stringify(data) }),
    updatePassword: (data: unknown) => fetchWrap('/auth/update-password', { method: 'PUT', body: JSON.stringify(data) }),
};

// Dashboard API
export const apiDashboard = {
    getUserStats: () => fetchWrap('/dashboard/user-stats'),
    getUpcomingSpecialDays: () => fetchWrap('/dashboard/upcoming-special-days'),
    getContentTypeDistribution: () => fetchWrap('/dashboard/content-type-distribution'),
    getRecentContents: () => fetchWrap('/dashboard/recent-contents'),
    getSpecialDayContentRatio: () => fetchWrap('/dashboard/specialday-content-ratio'),
};

// Quran API
export const apiQuran = {
    getSurahs: () => fetchWrap<any[]>('/quran/surahs'),
    getReciters: () => fetchWrap<any[]>('/quran/reciters'),
    getAyahs: (surahId: number) => fetchWrap<any[]>(`/quran/surahs/${surahId}/ayahs`),
    getSurahImages: (surahId: number) => fetchWrap<Record<number, string[]>>(`/quran/surahs/${surahId}/all-images`),
    getAyahImages: (surahId: number, ayahId: number) => fetchWrap<string[]>(`/quran/surahs/${surahId}/ayahs/${ayahId}/images`),
    getAyahAudio: (reciter: string, surahId: number, ayahId: number) => fetchWrap<{ audioPath: string }>(`/quran/audio/${reciter}/${surahId}/${ayahId}`),
    getFullSurahAudio: (reciter: string, surahId: number) => fetchWrap<string[]>(`/quran/audio/${reciter}/${surahId}/all`),
    getMealAudio: (language: string, surahId: number) => fetchWrap<{ url: string }>(`/quran/meal/${language}/${surahId}`),
    checkIntegrity: (surahId: number) => fetchWrap<any>(`/quran/surahs/${surahId}/integrity`),
};
