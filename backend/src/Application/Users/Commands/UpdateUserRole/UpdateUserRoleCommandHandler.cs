using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Enums;
using MediatR;
using Newtonsoft.Json;

namespace Application.Users.Commands.UpdateUserRole;

public class UpdateUserRoleCommandHandler : IRequestHandler<UpdateUserRoleCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateUserRoleCommandHandler(
        IApplicationDbContext context,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _context = context;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdateUserRoleCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Users.FindAsync(new object[] { request.Id }, cancellationToken);
        
        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        if (user.Id == _currentUserService.UserId)
            throw new Exception("Admin cannot change their own role.");

        var oldRole = user.Role;

        if (!Enum.TryParse<UserRole>(request.Role, true, out var newRole))
            throw new Exception("Geçersiz rol.");

        user.ChangeRole(newRole);

        await _context.SaveChangesAsync(cancellationToken);

        await _logRepository.AddAsync(new Domain.Entities.Log(
            _currentUserService.UserId ?? Guid.Empty,
            "UserRoleChanged",
            "Admin changed user role",
            JsonConvert.SerializeObject(new { 
                oldRole = oldRole.ToString(), 
                newRole = newRole.ToString(), 
                targetUserId = user.Id,
                changedByUserId = _currentUserService.UserId,
                ip = _currentUserService.IpAddress
            }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
