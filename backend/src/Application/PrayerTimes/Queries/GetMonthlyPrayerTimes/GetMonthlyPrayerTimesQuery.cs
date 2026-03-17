using MediatR;
using Application.PrayerTimes.Queries.GetPrayerTimeByDate;

namespace Application.PrayerTimes.Queries.GetMonthlyPrayerTimes;

// Bir lokasyona ait belirli bir yıl + ay içindeki tüm namaz vakitlerini getirir
public record GetMonthlyPrayerTimesQuery(
    int LocationId,   // İlçe kodu (örn: 9800)
    int Year,         // Yıl (örn: 2026)
    int Month         // Ay (1–12)
) : IRequest<List<PrayerTimeDto>>;
