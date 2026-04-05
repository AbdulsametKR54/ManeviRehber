using FluentValidation;

namespace Application.DailyContents.Commands.CreateDailyContent;

public class CreateDailyContentCommandValidator : AbstractValidator<CreateDailyContentCommand>
{
    public CreateDailyContentCommandValidator()
    {
        RuleFor(v => v.Title)
            .NotEmpty().WithMessage("Başlık boş olamaz.")
            .MaximumLength(200).WithMessage("Başlık en fazla 200 karakter olabilir.");

        RuleFor(v => v.Content)
            .NotEmpty().WithMessage("İçerik boş olamaz.")
            .MaximumLength(2000).WithMessage("İçerik en fazla 2000 karakter olabilir.");

        RuleFor(v => v.Type)
            .IsInEnum().WithMessage("Geçersiz içerik türü.");

        RuleFor(v => v.Date)
            .NotEmpty().WithMessage("Tarih boş olamaz.");
    }
}
