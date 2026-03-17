using MediatR;
using System;

namespace Application.DailyContents.Queries.GetPagedDailyContentsQuery;

public class GetPagedDailyContentsQuery : IRequest<GetPagedDailyContentsResponse>
{
    public string? Search { get; set; }
    public DateTime? Date { get; set; }
    public int? Type { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid? SpecialDayId { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}
