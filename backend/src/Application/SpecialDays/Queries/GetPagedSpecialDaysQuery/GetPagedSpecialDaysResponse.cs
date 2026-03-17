using Application.Common.DTOs.SpecialDays;
using System.Collections.Generic;

namespace Application.SpecialDays.Queries.GetPagedSpecialDaysQuery;

public class GetPagedSpecialDaysResponse
{
    public List<SpecialDayDto> Items { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
}
