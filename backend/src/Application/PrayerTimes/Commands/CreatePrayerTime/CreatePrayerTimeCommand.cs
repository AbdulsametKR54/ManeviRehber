using MediatR;

namespace Application.PrayerTimes.Commands.CreatePrayerTime;

// Yeni eklenen: LocationId → Hangi ilçeye ait olduğunu belirtiyor
public record CreatePrayerTimeCommand(
    int LocationId,          // İlçe kodu (örn: Akyazı = 9800)
    DateOnly Date,           // Miladî tarih
    TimeOnly Fajr,           // İmsak
    TimeOnly Sunrise,        // Güneş doğuşu
    TimeOnly Dhuhr,          // Öğle
    TimeOnly Asr,            // İkindi
    TimeOnly Maghrib,        // Akşam
    TimeOnly Sunset,         // Güneş batışı
    TimeOnly Isha,           // Yatsı
    string HijriDateLong     // Hicrî tarih (örn: "1 Ramazan 1447")
) : IRequest<Guid>;
