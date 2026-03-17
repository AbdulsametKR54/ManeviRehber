using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.Logs;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.Logs.Queries.GetLogs;

public class GetLogsQueryHandler : IRequestHandler<GetLogsQuery, List<LogDto>>
{
    private readonly IApplicationDbContext _context;

    public GetLogsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<LogDto>> Handle(GetLogsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Logs.AsNoTracking().AsQueryable();

        if (request.UserId.HasValue)
        {
            query = query.Where(l => l.UserId == request.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(request.Action))
        {
            query = query.Where(l => l.Action.Contains(request.Action));
        }

        if (request.StartDate.HasValue)
        {
            query = query.Where(l => l.CreatedAt >= request.StartDate.Value);
        }

        if (request.EndDate.HasValue)
        {
            query = query.Where(l => l.CreatedAt <= request.EndDate.Value);
        }

        return await query
            .OrderByDescending(l => l.CreatedAt)
            .Select(l => new LogDto
            {
                Id = l.Id,
                UserId = l.UserId,
                Action = l.Action,
                Description = l.Description,
                Data = l.Data,
                IpAddress = l.IpAddress,
                CreatedAt = l.CreatedAt
            })
            .ToListAsync(cancellationToken);
    }
}
