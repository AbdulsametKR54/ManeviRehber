using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BCrypt.Net;
using Application.Common.Interfaces;
using MediatR;
using Domain.Entities;
using Newtonsoft.Json;

namespace Application.Users.Commands.LoginUser;

public class LoginUserCommandHandler : IRequestHandler<LoginUserCommand, LoginUserResultDto>
{
    private readonly IUserRepository _userRepository;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public LoginUserCommandHandler(
        IUserRepository userRepository,
        IJwtTokenService jwtTokenService,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _userRepository = userRepository;
        _jwtTokenService = jwtTokenService;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<LoginUserResultDto> Handle(LoginUserCommand request, CancellationToken cancellationToken)
    {
        // 1) Kullanıcıyı email ile bul
        var user = await _userRepository.GetByEmailAsync(request.Email);
        if (user == null)
            throw new Exception("Email veya şifre hatalı.");

        if (!user.IsActive)
            throw new Exception("Hesabınız admin tarafından dondurulmuştur.");

        // 2) Şifreyi doğrula
        bool passwordMatches = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
        if (!passwordMatches)
            throw new Exception("Email veya şifre hatalı.");

        // 3) Token üret
        var token = _jwtTokenService.GenerateToken(user);

        // 4) DTO döndür (Domain'e göre düzeltildi)
        var result = new LoginUserResultDto
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email.Value,
            Language = user.Language.ToString(),
            Token = token
        };

        // 5) Logla
        await _logRepository.AddAsync(new Log(
            user.Id, // They just logged in, so we know their ID
            "User.Login",
            $"User {user.Id} ({user.Email.Value}) logged in successfully.",
            JsonConvert.SerializeObject(new { Email = user.Email.Value }),
            _currentUserService.IpAddress
        ));

        return result;
    }
}