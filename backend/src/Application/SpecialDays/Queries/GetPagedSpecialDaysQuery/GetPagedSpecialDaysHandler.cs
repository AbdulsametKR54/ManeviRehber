using Application.Common.DTOs.SpecialDays;
using Application.Common.Interfaces;
using MediatR;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Application.SpecialDays.Queries.GetPagedSpecialDaysQuery;

public class GetPagedSpecialDaysHandler : IRequestHandler<GetPagedSpecialDaysQuery, GetPagedSpecialDaysResponse>
{
    private readonly ISpecialDayRepository _repo;

    public GetPagedSpecialDaysHandler(ISpecialDayRepository repo)
    {
        _repo = repo;
    }

    public async Task<GetPagedSpecialDaysResponse> Handle(GetPagedSpecialDaysQuery request, CancellationToken cancellationToken)
    {
        var (items, totalCount) = await _repo.GetPagedAsync(
            request.Search,
            request.Page,
            request.PageSize
        );

        return new GetPagedSpecialDaysResponse
        {
            Items = items.Select(x => new SpecialDayDto
            {
                Id = x.Id,
                Title = x.Name ?? string.Empty,
                Name = x.Name ?? string.Empty,
                Description = x.Description ?? string.Empty,
                Date = x.Date
            }).ToList(),
            TotalCount = totalCount,
            Page = request.Page,
            PageSize = request.PageSize
        };
    }
}
