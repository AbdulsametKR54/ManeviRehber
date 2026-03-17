using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;

namespace Application.Settings.Commands.CreateSetting;

public class CreateSettingCommandHandler : IRequestHandler<CreateSettingCommand, Guid>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateSettingCommandHandler(
        IApplicationDbContext context,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _context = context;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Guid> Handle(CreateSettingCommand request, CancellationToken cancellationToken)
    {
        var entity = new Setting(request.Key, request.Value, request.Description);

        _context.Settings.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "Setting.Create",
            $"Created Setting {entity.Id}",
            JsonConvert.SerializeObject(new { New = entity }),
            _currentUserService.IpAddress
        ));

        return entity.Id;
    }
}
