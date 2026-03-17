using Application.Common.DTOs.Dashboard;
using Application.Common.Interfaces;
using Application.Dashboard.Queries;
using Application.Dashboard.Responses;
using MediatR;

namespace Application.Dashboard.Handlers;

public class GetUserStatsHandler : IRequestHandler<GetUserStatsQuery, UserStatsResponse>
{
    private readonly IDashboardRepository _repository;

    public GetUserStatsHandler(IDashboardRepository repository)
    {
        _repository = repository;
    }

    public async Task<UserStatsResponse> Handle(GetUserStatsQuery request, CancellationToken cancellationToken)
    {
        var stats = await _repository.GetUserStatsAsync();
        return new UserStatsResponse
        {
            Monthly = stats.Monthly,
            ActiveUsers = stats.ActiveUsers,
            PassiveUsers = stats.PassiveUsers,
            NewUsersThisMonth = stats.NewUsersThisMonth
        };
    }
}

public class GetUpcomingSpecialDaysHandler : IRequestHandler<GetUpcomingSpecialDaysQuery, IEnumerable<UpcomingSpecialDayDto>>
{
    private readonly IDashboardRepository _repository;

    public GetUpcomingSpecialDaysHandler(IDashboardRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<UpcomingSpecialDayDto>> Handle(GetUpcomingSpecialDaysQuery request, CancellationToken cancellationToken)
    {
        return await _repository.GetUpcomingSpecialDaysAsync(request.DaysAhead);
    }
}

public class GetContentTypeDistributionHandler : IRequestHandler<GetContentTypeDistributionQuery, ContentTypeDistributionDto>
{
    private readonly IDashboardRepository _repository;

    public GetContentTypeDistributionHandler(IDashboardRepository repository)
    {
        _repository = repository;
    }

    public async Task<ContentTypeDistributionDto> Handle(GetContentTypeDistributionQuery request, CancellationToken cancellationToken)
    {
        return await _repository.GetContentTypeDistributionAsync();
    }
}

public class GetRecentContentsHandler : IRequestHandler<GetRecentContentsQuery, IEnumerable<RecentContentDto>>
{
    private readonly IDashboardRepository _repository;

    public GetRecentContentsHandler(IDashboardRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<RecentContentDto>> Handle(GetRecentContentsQuery request, CancellationToken cancellationToken)
    {
        return await _repository.GetRecentContentsAsync(request.Count);
    }
}

public class GetSpecialDayContentRatioHandler : IRequestHandler<GetSpecialDayContentRatioQuery, SpecialDayContentRatioDto>
{
    private readonly IDashboardRepository _repository;

    public GetSpecialDayContentRatioHandler(IDashboardRepository repository)
    {
        _repository = repository;
    }

    public async Task<SpecialDayContentRatioDto> Handle(GetSpecialDayContentRatioQuery request, CancellationToken cancellationToken)
    {
        return await _repository.GetSpecialDayContentRatioAsync();
    }
}

public class GetDailyGrowthHandler : IRequestHandler<GetDailyGrowthQuery, DailyGrowthDto>
{
    private readonly IDashboardRepository _repository;
    public GetDailyGrowthHandler(IDashboardRepository repository) => _repository = repository;
    public async Task<DailyGrowthDto> Handle(GetDailyGrowthQuery request, CancellationToken cancellationToken) 
        => await _repository.GetDailyGrowthAsync();
}

public class GetWeeklyContentActivityHandler : IRequestHandler<GetWeeklyContentActivityQuery, WeeklyContentActivityDto>
{
    private readonly IDashboardRepository _repository;
    public GetWeeklyContentActivityHandler(IDashboardRepository repository) => _repository = repository;
    public async Task<WeeklyContentActivityDto> Handle(GetWeeklyContentActivityQuery request, CancellationToken cancellationToken) 
        => await _repository.GetWeeklyContentActivityAsync();
}

public class GetCategoryCountsHandler : IRequestHandler<GetCategoryCountsQuery, IEnumerable<CategoryCountDto>>
{
    private readonly IDashboardRepository _repository;
    public GetCategoryCountsHandler(IDashboardRepository repository) => _repository = repository;
    public async Task<IEnumerable<CategoryCountDto>> Handle(GetCategoryCountsQuery request, CancellationToken cancellationToken) 
        => await _repository.GetCategoryCountsAsync();
}

public class GetHealthCheckHandler : IRequestHandler<GetHealthCheckQuery, HealthCheckDto>
{
    private readonly IDashboardRepository _repository;
    public GetHealthCheckHandler(IDashboardRepository repository) => _repository = repository;
    public async Task<HealthCheckDto> Handle(GetHealthCheckQuery request, CancellationToken cancellationToken) 
        => await _repository.GetHealthCheckAsync();
}

public class GetSpecialDaysCountdownHandler : IRequestHandler<GetSpecialDaysCountdownQuery, IEnumerable<SpecialDayCountdownDto>>
{
    private readonly IDashboardRepository _repository;
    public GetSpecialDaysCountdownHandler(IDashboardRepository repository) => _repository = repository;
    public async Task<IEnumerable<SpecialDayCountdownDto>> Handle(GetSpecialDaysCountdownQuery request, CancellationToken cancellationToken) 
        => await _repository.GetSpecialDaysCountdownAsync();
}

public class GetContentTypeTrendsHandler : IRequestHandler<GetContentTypeTrendsQuery, IEnumerable<ContentTypeTrendDto>>
{
    private readonly IDashboardRepository _repository;
    public GetContentTypeTrendsHandler(IDashboardRepository repository) => _repository = repository;
    public async Task<IEnumerable<ContentTypeTrendDto>> Handle(GetContentTypeTrendsQuery request, CancellationToken cancellationToken) 
        => await _repository.GetContentTypeTrendsAsync();
}
