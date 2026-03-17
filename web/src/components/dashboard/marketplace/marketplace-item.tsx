import React from 'react';
import { Button } from '@/components/ui/button';
import { useDashboardWidgetsStore } from '@/store/dashboard-widgets';
import { Plus, Trash2, Info, RefreshCw } from 'lucide-react';
import { cn } from '@/lib/utils';
import { WIDGETS } from './widget-list';
import { Switch } from '@/components/ui/switch';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';

interface MarketplaceItemProps {
  id: string;
  title: string;
  description: string;
  preview: string;
}

export function MarketplaceItem({ id, title, description, preview }: MarketplaceItemProps) {
  const { 
    widgets, 
    setWidgetAdded, 
    autoRefresh, 
    autoRefreshInterval, 
    toggleAutoRefresh, 
    setAutoRefreshInterval 
  } = useDashboardWidgetsStore();
  
  const widget = widgets.find(w => w.id === id);
  const isAdded = widget?.added ?? false;
  const isRefreshing = autoRefresh[id] ?? false;
  const interval = autoRefreshInterval[id] ?? 60000;
  
  const addedCount = WIDGETS.filter((mw: any) => 
    widgets.find(w => w.id === mw.id)?.added
  ).length;
  
  const isLimitReached = addedCount >= 6;

  return (
    <div className={cn(
      "group relative flex flex-col gap-3 p-4 rounded-xl border border-border hover:bg-muted/50 transition-all",
      isAdded && "border-primary/20 bg-primary/5"
    )}>
      <div className="flex items-center justify-between">
        <div className="flex flex-col gap-1 max-w-[70%]">
          <h3 className="font-semibold text-sm">{title}</h3>
          <p className="text-xs text-muted-foreground line-clamp-1">{description}</p>
        </div>

        <div className="flex items-center gap-2">
          {/* Preview on Hover */}
          <div className="relative group/preview">
             <Info className="w-4 h-4 text-muted-foreground cursor-help" />
             <div className="absolute bottom-full right-0 mb-2 w-48 hidden group-hover/preview:block z-50 p-2 bg-popover border border-border rounded-lg shadow-xl animate-in fade-in slide-in-from-bottom-2">
                <div className="aspect-video bg-muted rounded overflow-hidden relative">
                  <div className="absolute inset-0 flex items-center justify-center text-[10px] text-muted-foreground italic">
                    Preview: {id}
                  </div>
                </div>
             </div>
          </div>

          {isAdded ? (
            <Button 
              variant="ghost" 
              size="sm" 
              onClick={() => setWidgetAdded(id, false)}
              className="text-red-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 h-8 px-2"
            >
              <Trash2 className="w-4 h-4 mr-1" /> Kaldır
            </Button>
          ) : (
            <div className="relative group/limit">
              <Button 
                variant="outline" 
                size="sm" 
                disabled={isLimitReached}
                onClick={() => setWidgetAdded(id, true)}
                className="h-8 px-2 border-primary/20 hover:border-primary text-primary"
              >
                <Plus className="w-4 h-4 mr-1" /> Ekle
              </Button>
              {isLimitReached && (
                <div className="absolute bottom-full right-0 mb-2 w-max hidden group-hover/limit:block z-50 px-2 py-1 bg-slate-800 text-white text-[10px] rounded shadow-lg">
                  Maksimum 6 widget ekleyebilirsin
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Auto-Refresh Controls - Only if added */}
      {isAdded && (
        <div className="flex items-center justify-between pt-2 border-t border-border/50">
          <div className="flex items-center gap-2">
            <RefreshCw className={cn("w-3 h-3 text-muted-foreground", isRefreshing && "animate-spin")} />
            <span className="text-[10px] font-medium text-muted-foreground uppercase tracking-wider">Otomatik Yenileme</span>
          </div>
          
          <div className="flex items-center gap-3">
            {isRefreshing && (
              <Select 
                value={interval.toString()} 
                onValueChange={(val) => setAutoRefreshInterval(id, parseInt(val))}
              >
                <SelectTrigger className="h-7 w-[80px] text-[10px] bg-transparent">
                  <SelectValue placeholder="Süre" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="30000">30s</SelectItem>
                  <SelectItem value="60000">60s</SelectItem>
                  <SelectItem value="120000">120s</SelectItem>
                </SelectContent>
              </Select>
            )}
            <Switch 
              checked={isRefreshing} 
              onCheckedChange={() => toggleAutoRefresh(id)}
              className="scale-75"
            />
          </div>
        </div>
      )}
    </div>
  );
}
