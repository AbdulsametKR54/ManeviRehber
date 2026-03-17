using System;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.Interfaces;
using Domain.Entities;
using MediatR;
using Newtonsoft.Json;

namespace Application.SpecialDays.Commands.CreateSpecialDay;

public class CreateSpecialDayCommandHandler : IRequestHandler<CreateSpecialDayCommand, Guid>
{
    private readonly IApplicationDbContext _context;
    private readonly ILogRepository _logRepository;
    private readonly ICurrentUserService _currentUserService;

    public CreateSpecialDayCommandHandler(
        IApplicationDbContext context,
        ILogRepository logRepository,
        ICurrentUserService currentUserService)
    {
        _context = context;
        _logRepository = logRepository;
        _currentUserService = currentUserService;
    }

    public async Task<Guid> Handle(CreateSpecialDayCommand request, CancellationToken cancellationToken)
    {
        var entity = new SpecialDay(request.Name, request.Date, request.Description);

        _context.SpecialDays.Add(entity);
        await _context.SaveChangesAsync(cancellationToken);

        await _logRepository.AddAsync(new Log(
            _currentUserService.UserId ?? Guid.Empty,
            "SpecialDay.Create",
            $"Created SpecialDay {entity.Id}",
            JsonConvert.SerializeObject(new { New = entity }),
            _currentUserService.IpAddress
        ));

        return entity.Id;
    }
}
