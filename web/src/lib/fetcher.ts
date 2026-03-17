import { apiFetch } from "./apiFetch";

export const fetcher = <T>(url: string): Promise<T> => apiFetch<T>(url);
