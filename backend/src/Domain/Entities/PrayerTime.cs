using System;
using Domain.Common;

namespace Domain.Entities;

public class PrayerTime : BaseEntity, IAggregateRoot
{
    // Bu namaz vakitlerinin hangi ilçeye ait olduğunu belirten ID
    // Örn: Akyazı = 9800, Düzce Merkez = 9550
    public int LocationId { get; private set; }

    // Namaz vakitlerinin ait olduğu miladî gün
    public DateOnly Date { get; private set; }

    // İmsak vakti (sabah namazı başlangıcı)
    public TimeOnly Fajr { get; private set; }

    // Güneş doğuşu (frontend animasyonları için gerekli)
    public TimeOnly Sunrise { get; private set; }

    // Öğle namazı vakti
    public TimeOnly Dhuhr { get; private set; }

    // İkindi namazı vakti
    public TimeOnly Asr { get; private set; }

    // Akşam namazı vakti
    public TimeOnly Maghrib { get; private set; }

    // Güneş batışı (frontend animasyonları için gerekli)
    public TimeOnly Sunset { get; private set; }

    // Yatsı namazı vakti
    public TimeOnly Isha { get; private set; }

    // Hicrî tarih (ör: "1 Ramazan 1447")
    public string HijriDateLong { get; private set; }

    // EF Core için gerekli boş constructor
    private PrayerTime() { }

    // Tam dolu constructor — yeni bir namaz vakti kaydı oluşturmak için
    public PrayerTime(
        int locationId,
        DateOnly date,
        TimeOnly fajr,
        TimeOnly sunrise,
        TimeOnly dhuhr,
        TimeOnly asr,
        TimeOnly maghrib,
        TimeOnly sunset,
        TimeOnly isha,
        string hijriDateLong)
    {
        // Tarih boş olamaz
        if (date == default)
            throw new ArgumentException("Date cannot be empty");

        LocationId = locationId;
        Date = date;
        Fajr = fajr;
        Sunrise = sunrise;
        Dhuhr = dhuhr;
        Asr = asr;
        Maghrib = maghrib;
        Sunset = sunset;
        Isha = isha;
        HijriDateLong = hijriDateLong;
    }

    // Namaz vakitlerini güncellemek için kullanılan domain metodu
    public void UpdateTimes(
        TimeOnly fajr,
        TimeOnly sunrise,
        TimeOnly dhuhr,
        TimeOnly asr,
        TimeOnly maghrib,
        TimeOnly sunset,
        TimeOnly isha,
        string hijriDateLong)
    {
        Fajr = fajr;
        Sunrise = sunrise;
        Dhuhr = dhuhr;
        Asr = asr;
        Maghrib = maghrib;
        Sunset = sunset;
        Isha = isha;
        HijriDateLong = hijriDateLong;

        // BaseEntity içindeki UpdatedAt alanını günceller
        SetUpdated();
    }
}
