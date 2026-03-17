using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Application.PrayerTimes.Queries.GetPrayerTimeByDate;

public class ExternalPrayerTimeDto
{
    public string Imsak { get; set; } = default!;
    public string Gunes { get; set; } = default!;        // Güneş doğuşu (Sunrise)
    public string GunesDogus { get; set; } = default!;   // Alternatif sunrise
    public string GunesBatis { get; set; } = default!;   // Sunset (DOĞRU ALAN)
    public string Ogle { get; set; } = default!;
    public string Ikindi { get; set; } = default!;
    public string Aksam { get; set; } = default!;
    public string Yatsi { get; set; } = default!;
    public string MiladiTarihKisa { get; set; } = default!;
    public string HicriTarihUzun { get; set; } = default!;
}

