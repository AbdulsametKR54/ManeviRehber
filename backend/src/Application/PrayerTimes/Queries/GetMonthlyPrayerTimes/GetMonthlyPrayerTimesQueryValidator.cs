using FluentValidation;

namespace Application.PrayerTimes.Queries.GetMonthlyPrayerTimes;

public class GetMonthlyPrayerTimesQueryValidator : AbstractValidator<GetMonthlyPrayerTimesQuery>
{
    public GetMonthlyPrayerTimesQueryValidator()
    {
        RuleFor(x => x.LocationId)
            .GreaterThan(0).WithMessage("Lokasyon ID geçerli olmalıdır.");

        RuleFor(x => x.Year)
            .GreaterThan(1900).WithMessage("Yıl 1900'dan büyük olmalıdır.")
            .LessThan(2100).WithMessage("Yıl 2100'dan küçük olmalıdır.");

        RuleFor(x => x.Month)
            .InclusiveBetween(1, 12).WithMessage("Ay 1 ile 12 arasında olmalıdır.");
    }
}
