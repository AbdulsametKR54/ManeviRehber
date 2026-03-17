using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Exceptions;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;

namespace Application.DailyContents.Commands.DeleteDailyContent;

public class DeleteDailyContentCommandHandler : IRequestHandler<DeleteDailyContentCommand, Unit>
{
    private readonly IDailyContentRepository _repository;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public DeleteDailyContentCommandHandler(
        IDailyContentRepository repository,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _repository = repository;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Unit> Handle(DeleteDailyContentCommand request, CancellationToken cancellationToken)
    {
        var entity = await _repository.GetByIdAsync(request.Id);

        if (entity == null)
            throw new NotFoundException(nameof(DailyContent), request.Id);

        await _repository.DeleteAsync(entity);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "DailyContent.Delete",
            $"Deleted DailyContent {entity.Id}",
            JsonConvert.SerializeObject(new { Old = entity }, new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore }),
            _currentUserService.IpAddress
        ));

        return Unit.Value;
    }
}
