using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.DailyContents;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Application.DailyContents.Queries.GetDailyContents;

public class GetDailyContentsQueryHandler : IRequestHandler<GetDailyContentsQuery, List<DailyContentDto>>
{
    private readonly IApplicationDbContext _context;

    public GetDailyContentsQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<DailyContentDto>> Handle(GetDailyContentsQuery request, CancellationToken cancellationToken)
    {
        var query = _context.DailyContents
            .Include(dc => dc.SpecialDay)
            .Include(dc => dc.DailyContentCategories)
                .ThenInclude(dcc => dcc.Category)
            .AsNoTracking()
            .AsQueryable();

        if (request.SpecialDayId.HasValue)
        {
            query = query.Where(dc => dc.SpecialDayId == request.SpecialDayId.Value);
        }

        if (request.CategoryId.HasValue)
        {
            query = query.Where(dc => dc.DailyContentCategories.Any(dcc => dcc.CategoryId == request.CategoryId.Value));
        }

        return await query
            .OrderByDescending(dc => dc.Date)
            .Select(dc => new DailyContentDto
            {
                Id = dc.Id,
                Title = dc.Title,
                Content = dc.Content,
                Type = dc.Type,
                Date = dc.Date,
                SpecialDayId = dc.SpecialDayId,
                SpecialDayName = dc.SpecialDay != null ? dc.SpecialDay.Name : null,
                Categories = dc.DailyContentCategories
                    .Select(c => new Application.Common.DTOs.Categories.CategoryDto 
                    { 
                        Id = c.Category.Id, 
                        Name = c.Category.Name 
                    }).ToList()
            })
            .ToListAsync(cancellationToken);
    }
}
