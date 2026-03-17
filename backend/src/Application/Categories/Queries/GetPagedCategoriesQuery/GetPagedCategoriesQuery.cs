using MediatR;

namespace Application.Categories.Queries.GetPagedCategoriesQuery;

public class GetPagedCategoriesQuery : IRequest<GetPagedCategoriesResponse>
{
    public string? Search { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}
