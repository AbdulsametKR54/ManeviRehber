using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Exceptions;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;

namespace Application.Settings.Commands.UpdateSetting;

public class UpdateSettingCommandHandler : IRequestHandler<UpdateSettingCommand, Unit>
{
    private readonly ISettingRepository _repository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateSettingCommandHandler(
        ISettingRepository repository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdateSettingCommand request, CancellationToken cancellationToken)
    {
        var entity = await _repository.GetByIdAsync(request.Id);

        if (entity == null)
            throw new NotFoundException(nameof(Setting), request.Id);

        var oldEntity = new 
        {
            entity.Key,
            entity.Value,
            entity.Description
        };

        entity.Update(request.Value, request.Description);

        await _repository.UpdateAsync(entity);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "Setting.Update",
            $"Updated Setting {entity.Id}",
            JsonConvert.SerializeObject(new { Old = oldEntity, New = entity }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
