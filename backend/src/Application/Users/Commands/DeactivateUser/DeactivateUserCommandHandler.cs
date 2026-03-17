using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using MediatR;
using Newtonsoft.Json;

namespace Application.Users.Commands.DeactivateUser;

public class DeactivateUserCommandHandler : IRequestHandler<DeactivateUserCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeactivateUserCommandHandler(
        IApplicationDbContext context,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _context = context;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeactivateUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Users.FindAsync(new object[] { request.Id }, cancellationToken);
        
        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        if (user.Id == _currentUserService.UserId)
            throw new Exception("Admin cannot deactivate their own account.");

        user.Deactivate();
        await _context.SaveChangesAsync(cancellationToken);

        await _logRepository.AddAsync(new Domain.Entities.Log(
            _currentUserService.UserId ?? Guid.Empty,
            "UserDeactivated",
            "Admin deactivated user",
            JsonConvert.SerializeObject(new { 
                targetUserId = user.Id,
                changedByUserId = _currentUserService.UserId,
                ip = _currentUserService.IpAddress
            }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
