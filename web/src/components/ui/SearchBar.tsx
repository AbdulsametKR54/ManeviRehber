"use client";

import { useEffect, useState } from "react";
import { Search } from "lucide-react";

interface SearchBarProps {
    value: string;
    onChange: (value: string) => void;
    placeholder?: string;
}

export function SearchBar({ value, onChange, placeholder = "Ara..." }: SearchBarProps) {
    const [searchTerm, setSearchTerm] = useState(value);

    useEffect(() => {
        // Only trigger onChange if the search term is different from the current prop value
        // to avoid unnecessary re-triggers from parent re-renders
        if (searchTerm === value) return;

        const timer = setTimeout(() => {
            onChange(searchTerm);
        }, 300);

        return () => clearTimeout(timer);
    }, [searchTerm, onChange, value]);

    useEffect(() => {
        setSearchTerm(value);
    }, [value]);

    return (
        <div className="relative w-full max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <input
                type="text"
                placeholder={placeholder}
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="flex h-10 w-full rounded-md border border-input bg-background pl-10 pr-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            />
        </div>
    );
}
