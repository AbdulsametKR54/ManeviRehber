using Application.Common.Interfaces;
using MediatR;
using Newtonsoft.Json;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Application.Users.Commands.UpdatePassword;

public class UpdatePasswordCommandHandler : IRequestHandler<UpdatePasswordCommand>
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdatePasswordCommandHandler(
        IUserRepository userRepository, 
        IPasswordHasher passwordHasher,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdatePasswordCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId);

        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        if (!_passwordHasher.Verify(request.OldPassword, user.PasswordHash))
            throw new Exception("Eski şifre yanlış.");

        var newHash = _passwordHasher.Hash(request.NewPassword);
        user.ChangePassword(newHash);
        user.SetUpdated();

        await _userRepository.UpdateAsync(user);

        await _logRepository.AddAsync(new Domain.Entities.Log(
            _currentUserService.UserId ?? Guid.Empty,
            "User.UpdatePassword",
            $"Updated Password for User {user.Id}",
            "{}", // Don't log passwords
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
