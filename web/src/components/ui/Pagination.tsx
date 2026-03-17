"use client";

import { Button } from "@/components/ui/button";

interface PaginationProps {
    totalCount: number;
    page: number;
    pageSize: number;
    onPageChange: (page: number) => void;
    onPageSizeChange: (pageSize: number) => void;
}

export function Pagination({
    totalCount,
    page,
    pageSize,
    onPageChange,
    onPageSizeChange
}: PaginationProps) {
    const totalPages = Math.ceil(totalCount / pageSize);

    return (
        <div className="mt-4 flex flex-col sm:flex-row items-center justify-between gap-4 border-t border-gray-200 dark:border-gray-800 pt-4">
            <span className="text-sm text-muted-foreground">
                Toplam {totalCount} kayıt, Sayfa {page} / {totalPages || 1}
            </span>
            
            <div className="flex items-center gap-4">
                <div className="flex items-center gap-2">
                    <span className="text-sm text-muted-foreground">Göster:</span>
                    <select
                        value={pageSize}
                        onChange={(e) => onPageSizeChange(Number(e.target.value))}
                        className="h-8 rounded-md border border-input bg-background px-2 text-sm"
                    >
                        <option value={10}>10</option>
                        <option value={25}>25</option>
                        <option value={50}>50</option>
                    </select>
                </div>

                <div className="flex items-center gap-1">
                    <Button 
                        variant="outline" 
                        size="sm" 
                        onClick={() => onPageChange(1)} 
                        disabled={page <= 1} 
                        className="h-8 px-2"
                        title="İlk Sayfa"
                    >
                        &laquo;
                    </Button>
                    <Button 
                        variant="outline" 
                        size="sm" 
                        onClick={() => onPageChange(Math.max(1, page - 1))} 
                        disabled={page <= 1} 
                        className="h-8"
                    >
                        Önceki
                    </Button>
                    <Button 
                        variant="outline" 
                        size="sm" 
                        onClick={() => onPageChange(Math.min(totalPages, page + 1))} 
                        disabled={page >= totalPages} 
                        className="h-8"
                    >
                        Sonraki
                    </Button>
                    <Button 
                        variant="outline" 
                        size="sm" 
                        onClick={() => onPageChange(totalPages)} 
                        disabled={page >= totalPages} 
                        className="h-8 px-2"
                        title="Son Sayfa"
                    >
                        &raquo;
                    </Button>
                </div>
            </div>
        </div>
    );
}
