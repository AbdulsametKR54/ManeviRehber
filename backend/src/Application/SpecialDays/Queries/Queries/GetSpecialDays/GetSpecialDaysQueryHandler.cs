using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.SpecialDays;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.SpecialDays.Queries.GetSpecialDays;

public class GetSpecialDaysQueryHandler : IRequestHandler<GetSpecialDaysQuery, List<SpecialDayDto>>
{
    private readonly IApplicationDbContext _context;

    public GetSpecialDaysQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<SpecialDayDto>> Handle(GetSpecialDaysQuery request, CancellationToken cancellationToken)
    {
        return await _context.SpecialDays
            .AsNoTracking()
            .OrderBy(sd => sd.Date)
            .Select(sd => new SpecialDayDto
            {
                Id = sd.Id,
                Name = sd.Name,
                Date = sd.Date,
                Description = sd.Description
            })
            .ToListAsync(cancellationToken);
    }
}
