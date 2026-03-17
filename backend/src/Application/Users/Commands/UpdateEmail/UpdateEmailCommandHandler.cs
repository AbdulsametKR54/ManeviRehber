using Application.Common.Interfaces;
using MediatR;
using Newtonsoft.Json;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Application.Users.Commands.UpdateEmail;

public class UpdateEmailCommandHandler : IRequestHandler<UpdateEmailCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateEmailCommandHandler(
        IUserRepository userRepository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdateEmailCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId);

        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        var oldEmail = user.Email.Value;

        user.ChangeEmail(request.Email);

        await _userRepository.UpdateAsync(user);

        await _logRepository.AddAsync(new Domain.Entities.Log(
            _currentUserService.UserId ?? Guid.Empty,
            "User.UpdateEmail",
            $"Updated Email for User {user.Id}",
            JsonConvert.SerializeObject(new { OldEmail = oldEmail, NewEmail = request.Email }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}