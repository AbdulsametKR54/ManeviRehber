using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FluentValidation;
namespace Application.Users.Commands.RegisterUser;
public sealed class RegisterUserCommandValidator 
    : AbstractValidator<RegisterUserCommand>
{
    public RegisterUserCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("İsim boş olamaz.")
            .MinimumLength(2).WithMessage("İsim en az 2 karakter olmalıdır.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email boş olamaz.")
            .EmailAddress().WithMessage("Geçerli bir email adresi giriniz.");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Şifre boş olamaz.")
            .MinimumLength(6).WithMessage("Şifre en az 6 karakter olmalıdır.");

        RuleFor(x => x.Language)
            .NotEmpty().WithMessage("Dil seçimi zorunludur.")
            .Must(lang => lang == "tr" || lang == "en")
            .WithMessage("Dil sadece 'tr' veya 'en' olabilir.");
    }
}