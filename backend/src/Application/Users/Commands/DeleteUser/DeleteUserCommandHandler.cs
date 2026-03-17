using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using MediatR;
using Newtonsoft.Json;

namespace Application.Users.Commands.DeleteUser;

public class DeleteUserCommandHandler : IRequestHandler<DeleteUserCommand, Unit>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteUserCommandHandler(
        IApplicationDbContext context,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _context = context;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteUserCommand request, CancellationToken cancellationToken)
    {
        var user = await _context.Users.FindAsync(new object[] { request.Id }, cancellationToken);
        
        if (user == null)
            throw new Exception("Kullanıcı bulunamadı.");

        if (user.Id == _currentUserService.UserId)
            throw new Exception("Admin cannot delete their own account from here.");

        _context.Users.Remove(user);
        await _context.SaveChangesAsync(cancellationToken);

        await _logRepository.AddAsync(new Domain.Entities.Log(
            _currentUserService.UserId ?? Guid.Empty,
            "UserDeleted",
            "Admin deleted user",
            JsonConvert.SerializeObject(new { 
                targetUserId = user.Id,
                deletedByUserId = _currentUserService.UserId,
                ip = _currentUserService.IpAddress
            }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
