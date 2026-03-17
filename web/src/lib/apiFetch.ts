export async function apiFetch<T = unknown>(
    endpoint: string,
    options: RequestInit = {}
): Promise<T> {
    // Token durumunu sadece browser ortamında localStorage'den doğrudan çekiyoruz (Zustand server side hata vermemesi için)
    let token = "";
    if (typeof window !== "undefined") {
        token = localStorage.getItem("token") || "";
    }

    const headers: Record<string, string> = {
        "Content-Type": "application/json",
        ...(options.headers as Record<string, string>),
    };

    if (token) {
        headers["Authorization"] = `Bearer ${token}`;
    }

    const config: RequestInit = {
        ...options,
        headers,
    };

    // Temel API prefix tanımı, duruma göre absolute URL verildiyse başına ekleme yapmaz.
    const baseUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5264/api";
    const isAbsoluteUrl = /^https?:\/\//i.test(endpoint);
    const url = isAbsoluteUrl ? endpoint : `${baseUrl}${endpoint}`;

    try {
        const response = await fetch(url, config);
        
        // 204 No Content işlemi
        if (response.status === 204) {
             const result = { success: true } as unknown as T;
             // Eğer sadece mutating veriler de başarılı döndürmek isterseniz aşağıdaki gibi toast fırlatabilirsiniz:
             if (options.method && options.method !== 'GET') {
                 if (typeof window !== 'undefined') {
                    const { toast } = await import("sonner");
                    toast.success("İşlem başarıyla tamamlandı.");
                 }
             }
             return result;
        }

        const data = await response.json().catch(() => ({}));

        // Başarılı Status Check
        if (response.ok) {
            // Sadece POST/PUT/DELETE veya isteğe bağlı mutating işlemlerinde toast gösteriyoruz (Her GET başarılı istekte spam yapmaması için idealdir).
            // Eğer her adımda göstermek istenirse options.method kontrolü iptal edilebilir. Kullanıcı deneyimini bozmaması için mutate olanlara ekliyoruz.
            if (options.method && options.method !== 'GET') {
                if (typeof window !== 'undefined') {
                    const { toast } = await import("sonner");
                    toast.success("İşlem başarıyla gerçekleşti.");
                }
            }
            return data;
        }

        // 400 - 499 Hata kodları (Validation vb. uyarılar)
        if (response.status >= 400 && response.status < 500) {
            const warningMessage = data?.message || data?.title || "Geçersiz istek! Lütfen bilgilerinizi kontrol edin.";
            if (typeof window !== 'undefined') {
                const { toast } = await import("sonner");
                toast.warning(warningMessage);
            }
            throw new Error(warningMessage);
        }

        // 500+ Hata kodları (Sunucu hataları)
        if (response.status >= 500) {
            const errorMessage = data?.message || "Sunucuyla bağlantı kurulamadı veya bir hata oluştu.";
            if (typeof window !== 'undefined') {
                const { toast } = await import("sonner");
                toast.error(errorMessage);
            }
            throw new Error(errorMessage);
        }

        throw new Error("Bilinmeyen bir hata oluştu.");
    } catch (error: unknown) {
        // Eğer zaten yakalanmış bir apiFetch hatası ise direkt throw ediyoruz.
        // Ağ (Network) hataları olursa veya json parser patlarsa Error Boundary/Global Toast'a düşsün:
        if (typeof window !== 'undefined' && error instanceof TypeError) {
             import("sonner").then(({ toast }) => {
                 toast.error("Ağ bağlantısı koptu veya sunucuya ulaşılamıyor.");
             });
        }
        throw error;
    }
}
