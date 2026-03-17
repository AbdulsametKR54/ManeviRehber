using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Newtonsoft.Json;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Application.Users.Commands.UpdateLanguage;

public class UpdateLanguageCommandHandler : IRequestHandler<UpdateLanguageCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateLanguageCommandHandler(
        IUserRepository userRepository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdateLanguageCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId);

        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        if (!Enum.TryParse<Language>(request.language, true, out var langEnum))
            throw new Exception("Geçersiz dil değeri.");

        var oldLanguage = user.Language.ToString();

        user.ChangeLanguage(langEnum);


        await _userRepository.UpdateAsync(user);

        await _logRepository.AddAsync(new Domain.Entities.Log(
            _currentUserService.UserId ?? Guid.Empty,
            "User.UpdateLanguage",
            $"Updated Language for User {user.Id}",
            JsonConvert.SerializeObject(new { OldLanguage = oldLanguage, NewLanguage = langEnum.ToString() }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}