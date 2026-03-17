using MediatR;
using Application.Common.Interfaces;
using Application.PrayerTimes.Queries.GetPrayerTimeByDate;
using Domain.Entities;

namespace Application.PrayerTimes.Queries.GetMonthlyPrayerTimes;

public class GetMonthlyPrayerTimesQueryHandler 
    : IRequestHandler<GetMonthlyPrayerTimesQuery, List<PrayerTimeDto>>
{
    private readonly IPrayerTimeRepository _repository;
    private readonly IEzanVaktiService _external;

    public GetMonthlyPrayerTimesQueryHandler(
        IPrayerTimeRepository repository,
        IEzanVaktiService external)
    {
        _repository = repository;
        _external = external;
    }

    public async Task<List<PrayerTimeDto>> Handle(GetMonthlyPrayerTimesQuery request, CancellationToken cancellationToken)
    {
        var daysInMonth = DateTime.DaysInMonth(request.Year, request.Month);

        // 1) DB'den oku
        var list = await _repository.GetMonthlyAsync(
            request.LocationId,
            request.Year,
            request.Month,
            cancellationToken
        );

        // Eğer ayın tüm günleri DB'de varsa → direkt dön
        if (list.Count == daysInMonth)
        {
            return list.Select(ToDto).ToList();
        }

        // 2) Eksik gün var → API'dan 30 günlük veri çek
        var apiList = await _external.GetPrayerTimesAsync(request.LocationId);

        // 3) API verisini filtrele (istenen ay)
        var filtered = apiList
            .Where(x =>
            {
                var d = DateOnly.ParseExact(x.MiladiTarihKisa, "dd.MM.yyyy");
                return d.Year == request.Year && d.Month == request.Month;
            })
            .ToList();

        // 4) Eksik günleri DB'ye kaydet
        foreach (var apiDay in filtered)
        {
            var date = DateOnly.ParseExact(apiDay.MiladiTarihKisa, "dd.MM.yyyy");

            // Zaten varsa ekleme
            if (list.Any(x => x.Date == date))
                continue;

            var entity = new PrayerTime(
                locationId: request.LocationId,
                date: date,
                fajr: TimeOnly.Parse(apiDay.Imsak),
                sunrise: TimeOnly.Parse(apiDay.Gunes),
                dhuhr: TimeOnly.Parse(apiDay.Ogle),
                asr: TimeOnly.Parse(apiDay.Ikindi),
                maghrib: TimeOnly.Parse(apiDay.Aksam),
                sunset: TimeOnly.Parse(apiDay.GunesBatis),
                isha: TimeOnly.Parse(apiDay.Yatsi),
                hijriDateLong: apiDay.HicriTarihUzun
            );

            await _repository.AddAsync(entity, cancellationToken);
        }

        // 5) DB'den tekrar oku ve dön
        var finalList = await _repository.GetMonthlyAsync(
            request.LocationId,
            request.Year,
            request.Month,
            cancellationToken
        );

        return finalList.Select(ToDto).ToList();
    }

    private static PrayerTimeDto ToDto(PrayerTime x)
    {
        return new PrayerTimeDto
        {
            Date = x.Date,
            Fajr = x.Fajr,
            Sunrise = x.Sunrise,
            Dhuhr = x.Dhuhr,
            Asr = x.Asr,
            Maghrib = x.Maghrib,
            Sunset = x.Sunset,
            Isha = x.Isha,
            HijriDateLong = x.HijriDateLong
        };
    }
}
