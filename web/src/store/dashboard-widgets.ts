import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { WIDGETS } from '@/components/dashboard/marketplace/widget-list';
import apiClient from '@/lib/axios';

export interface WidgetConfig {
  id: string;
  added: boolean;   // Marketplace'ten eklenip eklenmediği
  visible: boolean; // Dashboard'da o an gizli olup olmadığı
  order: number;
}

interface DashboardWidgetsState {
  widgets: WidgetConfig[];
  editMode: boolean;
  isLoading: boolean;
  autoRefresh: Record<string, boolean>;
  autoRefreshInterval: Record<string, number>;
  setEditMode: (on: boolean) => void;
  toggleWidgetVisibility: (id: string) => void;
  setWidgetAdded: (id: string, added: boolean) => void;
  setWidgets: (widgets: WidgetConfig[]) => void;
  toggleAutoRefresh: (id: string) => void;
  setAutoRefreshInterval: (id: string, interval: number) => void;
  fetchLayout: () => Promise<void>;
  saveLayout: () => void;
}

const defaultWidgets: WidgetConfig[] = [
  { id: "dailyGrowth", added: true, visible: true, order: 1 },
  { id: "weeklyContentActivity", added: true, visible: true, order: 2 },
  { id: "categoryDistribution", added: true, visible: true, order: 3 },
  { id: "healthCheck", added: true, visible: true, order: 4 },
  { id: "specialDaysCountdown", added: true, visible: true, order: 5 },
  { id: "contentTypeTrends", added: true, visible: true, order: 6 },
  { id: "userStats", added: false, visible: false, order: 7 },
  { id: "upcomingSpecialDays", added: false, visible: false, order: 8 },
  { id: "contentDistribution", added: false, visible: false, order: 9 },
  { id: "recentContents", added: false, visible: false, order: 10 },
  { id: "specialDayContentRatio", added: false, visible: false, order: 11 },
];

const defaultAutoRefresh = WIDGETS.reduce((acc, w) => ({ ...acc, [w.id]: w.defaultAutoRefresh ?? false }), {});
const defaultIntervals = WIDGETS.reduce((acc, w) => ({ ...acc, [w.id]: w.defaultInterval ?? 60000 }), {});

let saveTimeout: NodeJS.Timeout | null = null;

export const useDashboardWidgetsStore = create<DashboardWidgetsState>()(
  persist(
    (set, get) => ({
      widgets: defaultWidgets,
      editMode: false,
      isLoading: false,
      autoRefresh: defaultAutoRefresh,
      autoRefreshInterval: defaultIntervals,
      setEditMode: (on) => set({ editMode: on }),
      
      fetchLayout: async () => {
        try {
          set({ isLoading: true });
          const response = await apiClient.get('/dashboard/layout');
          const data = response.data;

          if (data && data.widgetsOrder) {
            const mergedWidgets = defaultWidgets.map(dw => {
              const orderIndex = data.widgetsOrder.indexOf(dw.id);
              const isAdded = orderIndex !== -1;
              const isVisible = data.visible?.[dw.id] ?? dw.visible;
              
              return {
                ...dw,
                added: isAdded,
                visible: isVisible,
                order: isAdded ? orderIndex + 1 : dw.order
              };
            });
            
            set({ 
              widgets: mergedWidgets.sort((a, b) => a.order - b.order),
              autoRefresh: { ...defaultAutoRefresh, ...(data.autoRefresh || {}) },
              autoRefreshInterval: { ...defaultIntervals, ...(data.autoRefreshInterval || {}) }
            });
          }
        } catch (error) {
          console.error('Failed to fetch dashboard layout:', error);
        } finally {
          set({ isLoading: false });
        }
      },

      saveLayout: () => {
        if (saveTimeout) clearTimeout(saveTimeout);
        
        saveTimeout = setTimeout(async () => {
          try {
            const { widgets, autoRefresh, autoRefreshInterval } = get();
            const addedWidgets = widgets
              .filter(w => w.added)
              .sort((a, b) => a.order - b.order);

            const layoutData = {
              widgetsOrder: addedWidgets.map(w => w.id),
              visible: widgets.reduce((acc, w) => ({ ...acc, [w.id]: w.visible }), {}),
              size: {}, 
              autoRefresh,
              autoRefreshInterval
            };

            await apiClient.post('/dashboard/layout', layoutData);
          } catch (error) {
            console.error('Failed to save dashboard layout:', error);
          }
        }, 500);
      },

      toggleAutoRefresh: (id) => {
        set((state) => ({
          autoRefresh: { ...state.autoRefresh, [id]: !state.autoRefresh[id] }
        }));
        get().saveLayout();
      },

      setAutoRefreshInterval: (id, interval) => {
        set((state) => ({
          autoRefreshInterval: { ...state.autoRefreshInterval, [id]: interval }
        }));
        get().saveLayout();
      },

      toggleWidgetVisibility: (id) => {
        set((state) => ({
          widgets: state.widgets.map(w => w.id === id ? { ...w, visible: !w.visible } : w)
        }));
        get().saveLayout();
      },

      setWidgetAdded: (id, added) => {
        if (added) {
          const knownIds = WIDGETS.map(mw => mw.id);
          const addedCount = get().widgets.filter(w => w.added && knownIds.includes(w.id)).length;
          if (addedCount >= 6) return;
        }
        
        set((state) => ({
          widgets: state.widgets.map(w => 
            w.id === id ? { ...w, added, visible: added } : w
          )
        }));
        get().saveLayout();
      },

      setWidgets: (widgets) => {
        set({ widgets });
        get().saveLayout();
      }
    }),
    {
      name: 'dashboard-widgets-storage',
      merge: (persistedState: any, currentState) => {
        if (!persistedState) return currentState;

        // Merge widgets: keep persisted visibility/order, but ensure all DEFINED widgets are present
        // This fixes the issue where new widgets added to the code don't appear for users with existing localStorage
        const mergedWidgets = currentState.widgets.map(dw => {
          const pw = (persistedState.widgets || []).find((w: any) => w.id === dw.id);
          if (pw) {
            return { ...dw, ...pw };
          }
          return dw;
        });

        return {
          ...currentState,
          ...persistedState,
          widgets: mergedWidgets
        };
      }
    }
  )
);
