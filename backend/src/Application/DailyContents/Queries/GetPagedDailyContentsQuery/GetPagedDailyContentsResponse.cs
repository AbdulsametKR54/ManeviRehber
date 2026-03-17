using Application.Common.DTOs.DailyContents;
using System.Collections.Generic;

namespace Application.DailyContents.Queries.GetPagedDailyContentsQuery;

public class GetPagedDailyContentsResponse
{
    public List<DailyContentDto> Items { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
}
