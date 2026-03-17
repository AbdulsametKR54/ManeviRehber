using Application.Common.DTOs.Categories;
using System.Collections.Generic;

namespace Application.Categories.Queries.GetPagedCategoriesQuery;

public class GetPagedCategoriesResponse
{
    public List<CategoryDto> Items { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
}
