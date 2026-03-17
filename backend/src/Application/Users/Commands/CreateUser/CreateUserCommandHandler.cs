using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using Domain.ValueObjects;
using Domain.Enums;
using MediatR;
using Newtonsoft.Json;

namespace Application.Users.Commands.CreateUser;

public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, Guid>
{
    private readonly IUserRepository _userRepository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateUserCommandHandler(
        IUserRepository userRepository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Guid> Handle(CreateUserCommand request, CancellationToken cancellationToken)
    {
        // Email zaten var mı kontrol et
        var existingUser = await _userRepository.GetByEmailAsync(request.Email);
        if (existingUser != null)
            throw new Exception("Bu email ile kayıtlı bir kullanıcı zaten var.");

        // Email VO oluştur
        var email = Email.Create(request.Email);

        // Şifre hashle
        var hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.Password);

        // string → enum (Language)
        var language = Enum.Parse<Language>(request.Language, true);

        // string → enum (UserRole)
        if (!Enum.TryParse<UserRole>(request.Role, true, out var roleEnum))
        {
            roleEnum = UserRole.User; // fallback
        }

        // User entity oluştur
        var user = new User(
            request.Name,
            email,
            hashedPassword,
            language,
            roleEnum
        );

        await _userRepository.AddAsync(user);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "User.Create",
            $"Created User {user.Id} ({user.Email.Value})",
            JsonConvert.SerializeObject(new { New = user }),
            _currentUserService.IpAddress
        ));

        return user.Id;
    }
}