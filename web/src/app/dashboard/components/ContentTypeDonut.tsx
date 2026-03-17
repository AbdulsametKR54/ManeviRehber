"use client";

import { PieChart, Pie, Cell, Tooltip as RechartsTooltip, ResponsiveContainer } from "recharts";

interface PieData {
    name: string;
    value: number;
}

export default function ContentTypeDonut({ pieData, colors }: { pieData: PieData[], colors: string[] }) {
    if (!pieData || pieData.length === 0) return null;

    return (
        <ResponsiveContainer width="100%" height="100%">
            <PieChart>
                <Pie
                    data={pieData}
                    cx="50%"
                    cy="50%"
                    innerRadius={55}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                    stroke="none"
                >
                    {pieData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />
                    ))}
                </Pie>
                <RechartsTooltip 
                    contentStyle={{ borderRadius: '8px', border: '1px solid var(--border)' }}
                    itemStyle={{ fontWeight: 'bold' }}
                />
            </PieChart>
        </ResponsiveContainer>
    );
}
