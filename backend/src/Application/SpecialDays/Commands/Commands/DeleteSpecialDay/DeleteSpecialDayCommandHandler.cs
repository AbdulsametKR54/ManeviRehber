using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Exceptions;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;

namespace Application.SpecialDays.Commands.DeleteSpecialDay;

public class DeleteSpecialDayCommandHandler : IRequestHandler<DeleteSpecialDayCommand, Unit>
{
    private readonly ISpecialDayRepository _repository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteSpecialDayCommandHandler(
        ISpecialDayRepository repository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteSpecialDayCommand request, CancellationToken cancellationToken)
    {
        var entity = await _repository.GetByIdAsync(request.Id);

        if (entity == null)
            throw new NotFoundException(nameof(SpecialDay), request.Id);

        await _repository.DeleteAsync(entity);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "SpecialDay.Delete",
            $"Deleted SpecialDay {entity.Id}",
            JsonConvert.SerializeObject(new { Old = entity }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
