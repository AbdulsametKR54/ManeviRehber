using Application.Common.DTOs.Categories;
using Application.Common.Interfaces;
using MediatR;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Application.Categories.Queries.GetPagedCategoriesQuery;

public class GetPagedCategoriesHandler : IRequestHandler<GetPagedCategoriesQuery, GetPagedCategoriesResponse>
{
    private readonly ICategoryRepository _repo;

    public GetPagedCategoriesHandler(ICategoryRepository repo)
    {
        _repo = repo;
    }

    public async Task<GetPagedCategoriesResponse> Handle(GetPagedCategoriesQuery request, CancellationToken cancellationToken)
    {
        var (items, totalCount) = await _repo.GetPagedAsync(
            request.Search,
            request.Page,
            request.PageSize
        );

        return new GetPagedCategoriesResponse
        {
            Items = items.Select(x => new CategoryDto
            {
                Id = x.Id,
                Name = x.Name ?? string.Empty,
                Description = x.Description ?? string.Empty
            }).ToList(),
            TotalCount = totalCount,
            Page = request.Page,
            PageSize = request.PageSize
        };
    }
}
