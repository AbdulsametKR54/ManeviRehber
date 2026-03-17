import { create } from "zustand";

interface DashboardLayoutState {
    isSidebarOpen: boolean;
    setSidebarOpen: (isOpen: boolean) => void;
    toggleSidebar: () => void;
}

export const useDashboardLayoutStore = create<DashboardLayoutState>((set) => ({
    isSidebarOpen: true,
    setSidebarOpen: (isOpen) => set({ isSidebarOpen: isOpen }),
    toggleSidebar: () => set((state) => ({ isSidebarOpen: !state.isSidebarOpen })),
}));
