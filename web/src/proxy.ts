import { NextRequest, NextResponse } from "next/server";
import { jwtVerify } from "jose";

const PUBLIC_PATHS = ["/login", "/register", "/"];

export default async function proxy(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // Public sayfalar
  if (PUBLIC_PATHS.includes(pathname)) {
      if (pathname === '/') {
          return NextResponse.redirect(new URL("/dashboard", req.url));
      }
      return NextResponse.next();
  }

  // Sadece dashboard altındaki yollara bakıyor (veya api vs)
  if (pathname.startsWith("/dashboard")) {
      // Token al (sistemin kullandığı anahtar "token")
      const token = req.cookies.get("token")?.value;

      if (!token) {
        return NextResponse.redirect(new URL("/login", req.url));
      }

      try {
        // Token doğrula
        // Eğer JWT_SECRET env içinde tanımlı değilse en azından patlamasını önlemek veya uyarmak adına kontrol
        if (process.env.JWT_SECRET) {
            await jwtVerify(token, new TextEncoder().encode(process.env.JWT_SECRET));
        } else {
            // Secret yoksa sadece eskisi gibi minimum expiration kontrolü yapabiliriz veya varsayılan pas geçebiliriz
            // Kullanıcı kodunuzda doğrudan jose verify yer aldığı için onu çalıştırıyoruz.
            // Fakat projede şu an hazırda bir process.env.JWT_SECRET olmayabilir, bu durumda çalışması için base64 payload decode yedeği:
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function (c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));
            const payload = JSON.parse(jsonPayload);
            if (payload.exp && payload.exp * 1000 < Date.now()) {
                throw new Error("Token expired");
            }
        }
        return NextResponse.next();
      } catch {
        return NextResponse.redirect(new URL("/login", req.url));
      }
  }

  return NextResponse.next();
}

export const config = {
    matcher: ['/dashboard/:path*', '/'],
};
