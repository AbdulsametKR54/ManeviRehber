using Application.Common.DTOs.Categories;
using Application.Common.DTOs.DailyContents;
using Application.Common.Interfaces;
using MediatR;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Application.DailyContents.Queries.GetPagedDailyContentsQuery;

public class GetPagedDailyContentsHandler : IRequestHandler<GetPagedDailyContentsQuery, GetPagedDailyContentsResponse>
{
    private readonly IDailyContentRepository _repo;

    public GetPagedDailyContentsHandler(IDailyContentRepository repo)
    {
        _repo = repo;
    }

    public async Task<GetPagedDailyContentsResponse> Handle(GetPagedDailyContentsQuery request, CancellationToken cancellationToken)
    {
        var (items, totalCount) = await _repo.GetPagedAsync(
            request.Search,
            request.Date,
            request.Type,
            request.CategoryId,
            request.SpecialDayId,
            request.Page,
            request.PageSize
        );

        return new GetPagedDailyContentsResponse
        {
            Items = items.Select(x => new DailyContentDto
            {
                Id = x.Id,
                Title = x.Title ?? string.Empty,
                Content = x.Content ?? string.Empty,
                Type = x.Type,
                TypeName = x.Type.ToString(),
                Date = x.Date,
                Categories = x.DailyContentCategories?.Select(dcc => new CategoryDto
                {
                    Id = dcc.Category.Id,
                    Name = dcc.Category.Name ?? string.Empty,
                    Description = dcc.Category.Description ?? string.Empty
                }).ToList() ?? new System.Collections.Generic.List<CategoryDto>(),
                SpecialDayId = x.SpecialDayId,
                SpecialDayName = x.SpecialDay?.Name
            }).ToList(),
            TotalCount = totalCount,
            Page = request.Page,
            PageSize = request.PageSize
        };
    }
}
