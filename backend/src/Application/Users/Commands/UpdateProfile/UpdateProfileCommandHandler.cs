using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using MediatR;
using Newtonsoft.Json;

namespace Application.Users.Commands.UpdateProfile;

public class UpdateProfileCommandHandler : IRequestHandler<UpdateProfileCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateProfileCommandHandler(
        IApplicationDbContext context,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _context = context;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdateProfileCommand request, CancellationToken cancellationToken)
    {
        var uid = _currentUserService.UserId;
        if (uid == null)
            throw new Exception("Yetkisiz erişim.");

        var user = await _context.Users.FindAsync(new object[] { uid.Value }, cancellationToken);
        
        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        var oldEmail = user.Email.Value;
        bool changed = false;

        if (!string.IsNullOrWhiteSpace(request.Email) && request.Email != oldEmail)
        {
            user.ChangeEmail(request.Email);
            changed = true;
        }

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            var hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.Password);
            user.ChangePassword(hashedPassword);
            changed = true;
        }

        if (changed)
        {
            await _context.SaveChangesAsync(cancellationToken);

            await _logRepository.AddAsync(new Domain.Entities.Log(
                user.Id,
                "UserProfileUpdated",
                "User updated their profile",
                JsonConvert.SerializeObject(new { 
                    oldEmail = oldEmail,
                    newEmail = user.Email.Value,
                    targetUserId = user.Id,
                    ip = _currentUserService.IpAddress
                }),
                _currentUserService.IpAddress
            ));
        }

        return Unit.Value;
    }
}
