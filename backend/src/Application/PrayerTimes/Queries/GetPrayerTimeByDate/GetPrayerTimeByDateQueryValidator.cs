using FluentValidation;

namespace Application.PrayerTimes.Queries.GetPrayerTimeByDate;

public class GetPrayerTimeByDateQueryValidator : AbstractValidator<GetPrayerTimeByDateQuery>
{
    public GetPrayerTimeByDateQueryValidator()
    {
        // Lokasyon boş olamaz
        RuleFor(x => x.LocationId)
            .GreaterThan(0).WithMessage("Lokasyon ID geçerli olmalıdır.");

        // Tarih boş olamaz
        RuleFor(x => x.Date)
            .NotEmpty().WithMessage("Tarih boş olamaz.")
            .Must(d => d != default).WithMessage("Geçerli bir tarih girilmelidir.");
    }
}
