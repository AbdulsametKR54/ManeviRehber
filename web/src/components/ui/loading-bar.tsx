"use client";

import { useEffect, useState } from "react";
import { usePathname, useSearchParams } from "next/navigation";

export function LoadingBar() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    let timeoutId: NodeJS.Timeout;
    
    // Asenkron olarak tetikleyerek React state güncellemelerinde çakışmayı önlüyoruz (ESLint çözümü)
    const startLoader = setTimeout(() => {
      setLoading(true);
      
      // Uygulama render süresini taklit eden bir timeout
      timeoutId = setTimeout(() => {
        setLoading(false);
      }, 400); // 400ms genellikle bir sayfa içi transition için ideal
    }, 0);

    return () => {
      clearTimeout(startLoader);
      clearTimeout(timeoutId);
    };
  }, [pathname, searchParams]);

  if (!loading) return null;

  return (
    <div className="fixed top-0 left-0 w-full h-[2px] z-50 pointer-events-none">
      <div 
        className="h-full bg-indigo-500 shadow-[0_0_10px_#6366f1,0_0_5px_#6366f1] transition-all duration-300 ease-out"
        style={{
          width: loading ? "100%" : "0%",
          animation: "loading-bar-sweep 0.4s ease-out forwards"
        }}
      />
      <style jsx global>{`
        @keyframes loading-bar-sweep {
          0% { width: 0%; opacity: 1; }
          60% { width: 80%; opacity: 1; }
          100% { width: 100%; opacity: 0; }
        }
      `}</style>
    </div>
  );
}
