using MediatR;

namespace Application.PrayerTimes.Queries.GetPrayerTimeByDate;

// Artık hem LocationId hem Date gerekiyor
public record GetPrayerTimeByDateQuery(
    int LocationId,   // İlçe kodu (örn: 9800)
    DateOnly Date     // Miladî tarih
) : IRequest<PrayerTimeDto>;
