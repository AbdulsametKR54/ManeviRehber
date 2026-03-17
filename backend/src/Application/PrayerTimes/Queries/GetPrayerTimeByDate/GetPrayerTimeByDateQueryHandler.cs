using MediatR;
using Application.Common.Interfaces;
using Microsoft.EntityFrameworkCore;
using Domain.Entities;

namespace Application.PrayerTimes.Queries.GetPrayerTimeByDate;

public class GetPrayerTimeByDateQueryHandler 
    : IRequestHandler<GetPrayerTimeByDateQuery, PrayerTimeDto>
{
    private readonly IPrayerTimeRepository _repository;
    private readonly IEzanVaktiService _external;

    public GetPrayerTimeByDateQueryHandler(
        IPrayerTimeRepository repository,
        IEzanVaktiService external)
    {
        _repository = repository;
        _external = external;
    }

    public async Task<PrayerTimeDto> Handle(GetPrayerTimeByDateQuery request, CancellationToken cancellationToken)
    {
        var dateOnly = request.Date;

        // 1) DB kontrol
        var entity = await _repository.GetByDateAsync(
            request.LocationId,
            dateOnly,
            cancellationToken
        );

        if (entity != null)
        {
            return new PrayerTimeDto
            {
                Date = entity.Date,
                Fajr = entity.Fajr,
                Sunrise = entity.Sunrise,
                Dhuhr = entity.Dhuhr,
                Asr = entity.Asr,
                Maghrib = entity.Maghrib,
                Sunset = entity.Sunset,
                Isha = entity.Isha,
                HijriDateLong = entity.HijriDateLong
            };
        }

        // 2) API'den çek
        var apiList = await _external.GetPrayerTimesAsync(request.LocationId);

        var apiDay = apiList.FirstOrDefault(x =>
            x.MiladiTarihKisa == request.Date.ToString("dd.MM.yyyy")
        );



        if (apiDay == null)
            throw new Exception("Bu tarih için namaz vakti bulunamadı.");

        // 3) API verisini PrayerTime entity'ine dönüştür
        var newEntity = new PrayerTime(
            locationId: request.LocationId,
            date: request.Date,
            fajr: TimeOnly.Parse(apiDay.Imsak),
            sunrise: TimeOnly.Parse(apiDay.Gunes),
            dhuhr: TimeOnly.Parse(apiDay.Ogle),
            asr: TimeOnly.Parse(apiDay.Ikindi),
            maghrib: TimeOnly.Parse(apiDay.Aksam),
            sunset: TimeOnly.Parse(apiDay.GunesBatis), // sunset yok, şimdilik böyle
            isha: TimeOnly.Parse(apiDay.Yatsi),
            hijriDateLong: apiDay.HicriTarihUzun
        );

        // 4) DB'ye kaydet
        await _repository.AddAsync(newEntity, cancellationToken);

        // 5) DTO olarak geri döndür
        return new PrayerTimeDto
        {
            Date = newEntity.Date,
            Fajr = newEntity.Fajr,
            Sunrise = newEntity.Sunrise,
            Dhuhr = newEntity.Dhuhr,
            Asr = newEntity.Asr,
            Maghrib = newEntity.Maghrib,
            Sunset = newEntity.Sunset,
            Isha = newEntity.Isha,
            HijriDateLong = newEntity.HijriDateLong
        };
    }
}
