using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.ZikrRecords;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.ZikrRecords.Queries.GetDailyZikrSummary;

public class GetDailyZikrSummaryQueryHandler : IRequestHandler<GetDailyZikrSummaryQuery, List<ZikrDailySummaryDto>>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public GetDailyZikrSummaryQueryHandler(IApplicationDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }

    public async Task<List<ZikrDailySummaryDto>> Handle(GetDailyZikrSummaryQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId ?? throw new UnauthorizedAccessException("Giriş yapmanız gerekiyor.");

        return await _context.ZikrRecords
            .Where(x => x.UserId == userId)
            .GroupBy(x => new { x.Date, x.Phrase })
            .Select(g => new ZikrDailySummaryDto
            {
                Date = g.Key.Date,
                Phrase = g.Key.Phrase,
                Total = g.Sum(x => x.Count)
            })
            .OrderByDescending(x => x.Date)
            .Take(30) // Let's take the last 30 days
            .ToListAsync(cancellationToken);
    }
}
