using FluentValidation;

namespace Application.PrayerTimes.Commands.CreatePrayerTime;

public class CreatePrayerTimeCommandValidator : AbstractValidator<CreatePrayerTimeCommand>
{
    public CreatePrayerTimeCommandValidator()
    {
        // Lokasyon boş olamaz
        RuleFor(x => x.LocationId)
            .GreaterThan(0).WithMessage("Lokasyon ID geçerli olmalıdır.");

        RuleFor(x => x.Date)
            .NotEmpty().WithMessage("Tarih boş olamaz.");

        RuleFor(x => x.Fajr)
            .NotEmpty().WithMessage("İmsak vakti boş olamaz.");

        RuleFor(x => x.Sunrise)
            .NotEmpty().WithMessage("Güneş doğuşu boş olamaz.");

        RuleFor(x => x.Dhuhr)
            .NotEmpty().WithMessage("Öğle vakti boş olamaz.");

        RuleFor(x => x.Asr)
            .NotEmpty().WithMessage("İkindi vakti boş olamaz.");

        RuleFor(x => x.Maghrib)
            .NotEmpty().WithMessage("Akşam vakti boş olamaz.");

        RuleFor(x => x.Sunset)
            .NotEmpty().WithMessage("Güneş batışı boş olamaz.");

        RuleFor(x => x.Isha)
            .NotEmpty().WithMessage("Yatsı vakti boş olamaz.");

        RuleFor(x => x.HijriDateLong)
            .NotEmpty().WithMessage("Hicrî tarih boş olamaz.")
            .MaximumLength(50).WithMessage("Hicrî tarih çok uzun.");
    }
}
