using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using BCrypt.Net;
using Newtonsoft.Json;

namespace Application.Users.Commands.RegisterUser;

public sealed class RegisterUserCommandHandler 
    : IRequestHandler<RegisterUserCommand, Guid>
{
    private readonly IUserRepository _userRepository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public RegisterUserCommandHandler(
        IUserRepository userRepository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Guid> Handle(RegisterUserCommand request, CancellationToken cancellationToken)
    {
        // 1) Email zaten var mı?
        var existingUser = await _userRepository.GetByEmailAsync(request.Email);
        if (existingUser is not null)
            throw new Exception("Bu email zaten kayıtlı.");

        // 2) Şifreyi hashle
        string passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

        // 3) Domain üzerinden User oluştur
        var user = User.Create(
            request.Name,
            request.Email,
            passwordHash,
            request.Language
        );

        // 4) Kaydet
        await _userRepository.AddAsync(user);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty, // Probably Empty since they aren't logged in yet
            "User.Register",
            $"Registered User {user.Id} ({user.Email.Value})",
            JsonConvert.SerializeObject(new { New = user }),
            _currentUserService.IpAddress
        ));

        // 5) Kullanıcı Id döndür
        return user.Id;
    }
}
