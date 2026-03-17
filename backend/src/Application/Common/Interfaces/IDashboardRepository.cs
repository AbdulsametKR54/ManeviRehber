using Application.Common.DTOs.Dashboard;

namespace Application.Common.Interfaces;

public interface IDashboardRepository
{
    Task<UserStatsDto> GetUserStatsAsync();
    Task<IEnumerable<UpcomingSpecialDayDto>> GetUpcomingSpecialDaysAsync(int daysAhead = 30);
    Task<ContentTypeDistributionDto> GetContentTypeDistributionAsync();
    Task<IEnumerable<RecentContentDto>> GetRecentContentsAsync(int count = 5);
    Task<SpecialDayContentRatioDto> GetSpecialDayContentRatioAsync();
    
    Task<DailyGrowthDto> GetDailyGrowthAsync();
    Task<WeeklyContentActivityDto> GetWeeklyContentActivityAsync();
    Task<IEnumerable<CategoryCountDto>> GetCategoryCountsAsync();
    Task<HealthCheckDto> GetHealthCheckAsync();
    Task<IEnumerable<SpecialDayCountdownDto>> GetSpecialDaysCountdownAsync();
    Task<IEnumerable<ContentTypeTrendDto>> GetContentTypeTrendsAsync();
}
