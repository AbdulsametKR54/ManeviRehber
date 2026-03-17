"use client";

import { 
    ComposedChart, Line, Bar, XAxis, YAxis, CartesianGrid, 
    Tooltip as RechartsTooltip, ResponsiveContainer, Legend 
} from "recharts";

export default function UserStatsChart({ data }: { data: any[] }) {
    if (!data || data.length === 0) return null;
    
    // Verileri isimlendirme ve formatlama amacıyla ön işleme
    const formattedData = data.map(item => ({
        name: item.name,
        totalUsers: item.totalUsers,
        trend: item.newUsers
    }));

    return (
        <ResponsiveContainer width="100%" height="100%">
            <ComposedChart data={formattedData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border)" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: 'var(--muted-foreground)', fontSize: 12 }} dy={10} />
                <YAxis yAxisId="left" axisLine={false} tickLine={false} tick={{ fill: 'var(--muted-foreground)', fontSize: 12 }} />
                <YAxis yAxisId="right" orientation="right" axisLine={false} tickLine={false} tick={{ fill: 'var(--muted-foreground)', fontSize: 12 }} hide />
                <RechartsTooltip
                    contentStyle={{ backgroundColor: 'var(--card)', borderRadius: '8px', border: '1px solid var(--border)', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                    itemStyle={{ fontWeight: '500' }}
                    labelFormatter={(label) => `Tarih: ${label}`}
                    formatter={(value: any, name: any) => [`${value} kullanıcı`, name]}
                />
                <Legend verticalAlign="top" height={36} wrapperStyle={{ paddingBottom: '10px' }} />
                <Bar yAxisId="left" dataKey="totalUsers" name="Kullanıcı Sayısı" fill="#6366f1" radius={[4, 4, 0, 0]} />
                <Line yAxisId="right" type="monotone" dataKey="trend" name="Trend" stroke="#10b981" strokeWidth={3} dot={{ r: 4 }} activeDot={{ r: 6 }} />
            </ComposedChart>
        </ResponsiveContainer>
    );
}
