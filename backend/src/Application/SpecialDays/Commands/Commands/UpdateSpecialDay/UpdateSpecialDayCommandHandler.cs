using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Exceptions;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;

namespace Application.SpecialDays.Commands.UpdateSpecialDay;

public class UpdateSpecialDayCommandHandler : IRequestHandler<UpdateSpecialDayCommand, Unit>
{
    private readonly ISpecialDayRepository _repository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public UpdateSpecialDayCommandHandler(
        ISpecialDayRepository repository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(UpdateSpecialDayCommand request, CancellationToken cancellationToken)
    {
        var entity = await _repository.GetByIdAsync(request.Id);

        if (entity == null)
            throw new NotFoundException(nameof(SpecialDay), request.Id);

        var oldEntity = new 
        {
            entity.Name,
            entity.Date,
            entity.Description
        };

        entity.Update(request.Name, request.Date, request.Description);

        await _repository.UpdateAsync(entity);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "SpecialDay.Update",
            $"Updated SpecialDay {entity.Id}",
            JsonConvert.SerializeObject(new { Old = oldEntity, New = entity }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
