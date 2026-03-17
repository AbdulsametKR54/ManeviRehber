using System.Threading;
using System.Threading.Tasks;
using Application.Common.DTOs.DailyContents;
using Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace Application.DailyContents.Queries.GetDailyContentById;

public class GetDailyContentByIdQueryHandler : IRequestHandler<GetDailyContentByIdQuery, DailyContentDto?>
{
    private readonly IApplicationDbContext _context;

    public GetDailyContentByIdQueryHandler(IApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<DailyContentDto?> Handle(GetDailyContentByIdQuery request, CancellationToken cancellationToken)
    {
        var entity = await _context.DailyContents
            .Include(dc => dc.SpecialDay)
            .Include(dc => dc.DailyContentCategories)
                .ThenInclude(dcc => dcc.Category)
            .AsNoTracking()
            .FirstOrDefaultAsync(dc => dc.Id == request.Id, cancellationToken);

        if (entity == null)
            return null;

        return new DailyContentDto
        {
            Id = entity.Id,
            Title = entity.Title,
            Content = entity.Content,
            Type = entity.Type,
            Date = entity.Date,
            SpecialDayId = entity.SpecialDayId,
            SpecialDayName = entity.SpecialDay != null ? entity.SpecialDay.Name : null,
            Categories = entity.DailyContentCategories
                .Select(c => new Application.Common.DTOs.Categories.CategoryDto 
                { 
                    Id = c.Category.Id, 
                    Name = c.Category.Name 
                }).ToList()
        };
    }
}
