export const WIDGETS = [
  {
    id: "dailyGrowth",
    title: "Günlük İçerik Artışı",
    description: "Bugün ve dün eklenen içerik sayıları",
    preview: "/previews/daily-growth.png",
    defaultAutoRefresh: true,
    defaultInterval: 60000
  },
  {
    id: "weeklyContentActivity",
    title: "Haftalık İçerik Aktivitesi",
    description: "Son 7 gün içerik ekleme grafiği",
    preview: "/previews/weekly-activity.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  },
  {
    id: "categoryDistribution",
    title: "Kategori Bazlı İçerik Sayısı",
    description: "Tüm kategorilerdeki içerik dağılımı",
    preview: "/previews/category-distribution.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  },
  {
    id: "healthCheck",
    title: "Sistem Sağlığı",
    description: "Uptime, response time ve hata oranı",
    preview: "/previews/health-check.png",
    defaultAutoRefresh: true,
    defaultInterval: 30000
  },
  {
    id: "specialDaysCountdown",
    title: "Özel Gün Geri Sayım",
    description: "En yakın 3 özel güne kalan süre",
    preview: "/previews/special-days.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  },
  {
    id: "contentTypeTrends",
    title: "İçerik Türü Trendleri",
    description: "Son 30 gün içerik türü grafiği",
    preview: "/previews/content-type-trends.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  },

  // Mevcut 5 widget
  { 
    id: "userStats", 
    title: "Kullanıcı İstatistikleri", 
    description: "Aktif/pasif kullanıcılar", 
    preview: "/previews/user-stats.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  },
  { 
    id: "upcomingSpecialDays", 
    title: "Yaklaşan Özel Günler", 
    description: "En yakın özel günler", 
    preview: "/previews/upcoming-days.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  },
  { 
    id: "contentDistribution", 
    title: "İçerik Dağılımı", 
    description: "İçerik türü dağılımı", 
    preview: "/previews/content-distribution.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  },
  { 
    id: "recentContents", 
    title: "Son Eklenen İçerikler", 
    description: "Son eklenen içerikler", 
    preview: "/previews/recent-contents.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  },
  { 
    id: "specialDayContentRatio", 
    title: "Özel Gün İçerik Oranı", 
    description: "Özel gün içerik yüzdesi", 
    preview: "/previews/specialday-ratio.png",
    defaultAutoRefresh: false,
    defaultInterval: 60000
  }
];
