namespace Application.PrayerTimes.Queries.GetPrayerTimeByDate;

public class PrayerTimeDto
{
    public DateOnly Date { get; set; }
    public TimeOnly Fajr { get; set; }
    public TimeOnly Sunrise { get; set; }
    public TimeOnly Dhuhr { get; set; }
    public TimeOnly Asr { get; set; }
    public TimeOnly Maghrib { get; set; }
    public TimeOnly Sunset { get; set; }
    public TimeOnly Isha { get; set; }
    public string HijriDateLong { get; set; } = string.Empty;
}
