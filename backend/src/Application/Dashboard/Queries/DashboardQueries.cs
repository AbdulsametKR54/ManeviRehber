using Application.Common.DTOs.Dashboard;
using Application.Dashboard.Responses;
using MediatR;

namespace Application.Dashboard.Queries;

public class GetUserStatsQuery : IRequest<UserStatsResponse> { }

public class GetUpcomingSpecialDaysQuery : IRequest<IEnumerable<UpcomingSpecialDayDto>> 
{ 
    public int DaysAhead { get; set; } = 30; 
}

public class GetContentTypeDistributionQuery : IRequest<ContentTypeDistributionDto> { }

public class GetRecentContentsQuery : IRequest<IEnumerable<RecentContentDto>> 
{ 
    public int Count { get; set; } = 5; 
}

public class GetSpecialDayContentRatioQuery : IRequest<SpecialDayContentRatioDto> { }

public class GetDailyGrowthQuery : IRequest<DailyGrowthDto> { }

public class GetWeeklyContentActivityQuery : IRequest<WeeklyContentActivityDto> { }

public class GetCategoryCountsQuery : IRequest<IEnumerable<CategoryCountDto>> { }

public class GetHealthCheckQuery : IRequest<HealthCheckDto> { }

public class GetSpecialDaysCountdownQuery : IRequest<IEnumerable<SpecialDayCountdownDto>> { }

public class GetContentTypeTrendsQuery : IRequest<IEnumerable<ContentTypeTrendDto>> { }
