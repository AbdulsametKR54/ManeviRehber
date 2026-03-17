using FluentValidation;

namespace Application.Users.Commands.UpdateLanguage;

public class UpdateLanguageCommandValidator : AbstractValidator<UpdateLanguageCommand>
{
    public UpdateLanguageCommandValidator()
    { 
        RuleFor(x => x.language)
            .NotEmpty().WithMessage("Dil boş olamaz.")
            .Must(lang => lang.ToLower() == "tr" || lang.ToLower() == "en" || lang.ToLower() == "ar")
            .WithMessage("Geçerli bir dil giriniz. (tr, en, ar)");
    }
}