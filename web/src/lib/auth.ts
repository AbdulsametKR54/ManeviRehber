import { create } from "zustand";

interface AuthState {
    token: string | null;
    user: { name: string; email: string; id: string; role?: string } | null;
    setToken: (token: string | null) => void;
    setUser: (user: { name: string; email: string; id: string; role?: string } | null) => void;
    login: (token: string, user: { name: string; email: string; id: string; role?: string }) => void;
    removeToken: () => void;
    logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
    token: typeof window !== "undefined" ? localStorage.getItem("token") : null,
    user: typeof window !== "undefined" ? JSON.parse(localStorage.getItem("user") || "null") : null,
    setToken: (token) => {
        if (typeof window !== "undefined") {
            if (token) {
                localStorage.setItem("token", token);
                document.cookie = `token=${token}; path=/; max-age=86400; SameSite=Lax`;
            } else {
                localStorage.removeItem("token");
                document.cookie = `token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
            }
        }
        set({ token });
    },
    setUser: (user) => {
        if (typeof window !== "undefined") {
            if (user) localStorage.setItem("user", JSON.stringify(user));
            else localStorage.removeItem("user");
        }
        set({ user });
    },
    login: (token, user) => {
        if (typeof window !== "undefined") {
            localStorage.setItem("token", token);
            localStorage.setItem("user", JSON.stringify(user));
            document.cookie = `token=${token}; path=/; max-age=86400; SameSite=Lax`;
        }
        set({ token, user });
    },
    removeToken: () => {
        if (typeof window !== "undefined") {
            localStorage.removeItem("token");
            localStorage.removeItem("user");
            document.cookie = `token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
        }
        set({ token: null, user: null });
    },
    logout: () => {
        if (typeof window !== "undefined") {
            localStorage.removeItem("token");
            localStorage.removeItem("user");
            document.cookie = `token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
        }
        set({ token: null, user: null });
    },
}));

export const getToken = () => {
    return useAuthStore.getState().token;
};

export const setToken = (token: string) => {
    useAuthStore.getState().setToken(token);
};

export const removeToken = () => {
    useAuthStore.getState().removeToken();
};
