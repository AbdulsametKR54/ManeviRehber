import React from 'react';
import { useDashboardWidgetsStore } from '@/store/dashboard-widgets';
import { Eye, EyeOff, Edit2, Check, GripVertical } from 'lucide-react';
import { cn } from '@/lib/utils';
import Image from 'next/image';

interface WidgetWrapperProps {
  id: string;
  children: React.ReactNode;
  className?: string; // e.g. md:col-span-2
  dragHandleProps?: any;
}

export function WidgetWrapper({ id, children, className, dragHandleProps }: WidgetWrapperProps) {
  const { editMode, widgets, toggleWidgetVisibility } = useDashboardWidgetsStore();
  const widget = widgets.find(w => w.id === id);

  if (!widget) return null;

  // Normal mode: do not render if not visible
  if (!editMode && !widget.visible) {
    return null;
  }

  return (
    <div className={cn(
        "relative rounded-2xl bg-card shadow-sm border border-border flex flex-col h-full group", 
        !widget.visible && editMode && "opacity-40 grayscale transition-all",
        className
    )}>
      {/* Edit Mode Overlay Control */}
      {editMode && (
        <div className="absolute top-3 left-3 right-3 z-10 flex items-center justify-between pointer-events-none">
          <div 
            {...dragHandleProps}
            className="p-1.5 bg-background/80 backdrop-blur-sm hover:bg-muted rounded-md shadow-sm border border-border cursor-grab active:cursor-grabbing pointer-events-auto"
            title="Sırala"
          >
            <GripVertical className="w-4 h-4 text-muted-foreground" />
          </div>

          <div className="flex items-center gap-2 bg-background/80 backdrop-blur-sm p-1.5 rounded-md shadow-sm border border-border pointer-events-auto">
            <button 
              type="button" 
              onClick={() => toggleWidgetVisibility(id)}
              className="p-1 hover:bg-muted rounded-full transition-colors text-muted-foreground hover:text-foreground"
              title={widget.visible ? "Gizle" : "Göster"}
            >
              {widget.visible ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
            </button>
          </div>
        </div>
      )}
      
      {/* Widget Content */}
      <div className={cn("p-6 flex-1 flex flex-col", (editMode && !widget.visible) && "pointer-events-none")}>
        {children}
      </div>
    </div>
  );
}
