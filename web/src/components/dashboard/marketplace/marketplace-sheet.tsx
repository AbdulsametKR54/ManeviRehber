import React from 'react';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { WIDGETS } from './widget-list';
import { MarketplaceItem } from './marketplace-item';
import { useDashboardWidgetsStore } from '@/store/dashboard-widgets';
import { cn } from '@/lib/utils';

interface MarketplaceSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function MarketplaceSheet({ open, onOpenChange }: MarketplaceSheetProps) {
  const { widgets } = useDashboardWidgetsStore();
  
  // Sadece tanımlı (WIDGETS listesinde olan) ve EKLENMİŞ olanları say
  const addedCount = WIDGETS.filter((mw: any) => 
    widgets.find(w => w.id === mw.id)?.added
  ).length;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="sm:max-w-md overflow-y-auto">
        <SheetHeader className="mb-6">
          <SheetTitle>Widget Marketplace</SheetTitle>
          <SheetDescription>
            Dashboard'a eklemek istediğiniz bileşenleri seçin. 
            Maksimum 6 widget eklenebilir.
          </SheetDescription>
          <div className="mt-2 flex items-center gap-2">
            <div className="flex-1 h-1.5 bg-muted rounded-full overflow-hidden">
               <div 
                 className={cn(
                   "h-full transition-all duration-300",
                   addedCount < 5 ? "bg-primary" : addedCount === 5 ? "bg-orange-500" : "bg-red-500"
                 )}
                 style={{ width: `${(addedCount / 6) * 100}%` }}
               />
            </div>
            <span className="text-[10px] font-medium text-muted-foreground whitespace-nowrap">
              {addedCount} / 6 Eklendi
            </span>
          </div>
        </SheetHeader>

        <div className="flex flex-col gap-3 pb-10">
           {WIDGETS.map((widget) => (
             <MarketplaceItem key={widget.id} {...widget} />
           ))}
        </div>
      </SheetContent>
    </Sheet>
  );
}
