using Application.Common.DTOs.Dashboard;
using Application.Common.Interfaces;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class DashboardRepository : IDashboardRepository
{
    private readonly ApplicationDbContext _context;

    public DashboardRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UserStatsDto> GetUserStatsAsync()
    {
        var now = DateTime.UtcNow;
        var startOfMonth = new DateTime(now.Year, now.Month, 1);
        
        var activeUsers = await _context.Users.CountAsync(u => u.IsActive);
        var passiveUsers = await _context.Users.CountAsync(u => !u.IsActive);
        var newUsersThisMonth = await _context.Users.CountAsync(u => u.CreatedAt >= startOfMonth);

        var sixMonthsAgo = startOfMonth.AddMonths(-5);
        var groupedData = await _context.Users
            .Where(u => u.CreatedAt >= sixMonthsAgo)
            .GroupBy(u => new { u.CreatedAt.Year, u.CreatedAt.Month })
            .Select(g => new { g.Key.Year, g.Key.Month, Count = g.Count() })
            .ToListAsync();

        var monthlyData = groupedData
            .Select(g => new MonthlyUserStatDto
            {
                Month = $"{g.Year}-{g.Month:D2}",
                NewUsers = g.Count
            })
            .OrderBy(m => m.Month)
            .ToList();

        var usersBeforeSixMonths = await _context.Users.CountAsync(u => u.CreatedAt < sixMonthsAgo);
        var currentTotal = usersBeforeSixMonths;
        
        foreach (var m in monthlyData)
        {
            currentTotal += m.NewUsers;
            m.TotalUsers = currentTotal;
        }

        return new UserStatsDto
        {
            ActiveUsers = activeUsers,
            PassiveUsers = passiveUsers,
            NewUsersThisMonth = newUsersThisMonth,
            Monthly = monthlyData
        };
    }

    public async Task<IEnumerable<UpcomingSpecialDayDto>> GetUpcomingSpecialDaysAsync(int daysAhead = 30)
    {
        var today = DateTime.UtcNow.Date;
        var todayDateOnly = DateOnly.FromDateTime(today);
        var futureDateOnly = DateOnly.FromDateTime(today.AddDays(daysAhead));

        var days = await _context.SpecialDays
            .AsNoTracking()
            .Where(sd => sd.Date >= todayDateOnly && sd.Date <= futureDateOnly)
            .OrderBy(sd => sd.Date)
            .Select(sd => new { sd.Id, sd.Name, sd.Date })
            .ToListAsync();

        return days.Select(sd => new UpcomingSpecialDayDto
        {
            Id = sd.Id,
            Title = sd.Name, 
            Date = sd.Date.ToString("yyyy-MM-dd")
        }).ToList();
    }

    public async Task<ContentTypeDistributionDto> GetContentTypeDistributionAsync()
    {
        var grouped = await _context.DailyContents
            .GroupBy(c => c.Type)
            .Select(g => new { Type = g.Key, Count = g.Count() })
            .ToListAsync();

        var dist = new ContentTypeDistributionDto();
        foreach (var item in grouped)
        {
            var typeVal = (int)item.Type;
            if (typeVal == 1) dist.Ayet = item.Count;
            else if (typeVal == 2) dist.Hadis = item.Count;
            else if (typeVal == 3) dist.Soz = item.Count;
            else if (typeVal == 4) dist.Dua = item.Count;
        }

        return dist;
    }

    public async Task<IEnumerable<RecentContentDto>> GetRecentContentsAsync(int count = 5)
    {
        var recentContents = await _context.DailyContents
            .AsNoTracking()
            .OrderByDescending(c => c.CreatedAt)
            .Take(count)
            .Select(c => new 
            {
                c.Id,
                c.Title,
                c.Type,
                c.CreatedAt,
                Categories = c.DailyContentCategories.Select(dcc => dcc.Category.Name).ToList()
            })
            .ToListAsync();

        var recent = recentContents.Select(c => new RecentContentDto
        {
            Id = c.Id,
            Title = c.Title,
            TypeName = GetTypeName((int)c.Type),
            Date = c.CreatedAt.ToString("yyyy-MM-dd"),
            Categories = c.Categories
        }).ToList();

        return recent;
    }

    private static string GetTypeName(int type)
    {
        return type switch
        {
            1 => "Ayet",
            2 => "Hadis",
            3 => "Söz",
            4 => "Dua",
            _ => "Bilinmeyen"
        };
    }

    public async Task<SpecialDayContentRatioDto> GetSpecialDayContentRatioAsync()
    {
        var specialDayContents = await _context.DailyContents.CountAsync(c => c.SpecialDayId != null);
        var normalContents = await _context.DailyContents.CountAsync(c => c.SpecialDayId == null);

        return new SpecialDayContentRatioDto
        {
            SpecialDayContents = specialDayContents,
            NormalContents = normalContents
        };
    }

    public async Task<DailyGrowthDto> GetDailyGrowthAsync()
    {
        var today = DateTime.UtcNow.Date;
        var yesterday = today.AddDays(-1);
        
        var todayCount = await _context.DailyContents.CountAsync(c => c.CreatedAt >= today);
        var yesterdayCount = await _context.DailyContents.CountAsync(c => c.CreatedAt >= yesterday && c.CreatedAt < today);
        
        var difference = todayCount - yesterdayCount;
        var trend = difference > 0 ? "up" : (difference < 0 ? "down" : "equal");

        return new DailyGrowthDto
        {
            TodayCount = todayCount,
            YesterdayCount = yesterdayCount,
            Difference = difference,
            Trend = trend
        };
    }

    public async Task<WeeklyContentActivityDto> GetWeeklyContentActivityAsync()
    {
        var today = DateTime.UtcNow.Date;
        var startDate = today.AddDays(-6); 

        var weeklyData = await _context.DailyContents
            .Where(c => c.CreatedAt >= startDate)
            .GroupBy(c => c.CreatedAt.Date)
            .Select(g => new { Date = g.Key, Count = g.Count() })
            .ToListAsync();

        var dto = new WeeklyContentActivityDto();
        
        for (int i = 0; i < 7; i++)
        {
            var date = startDate.AddDays(i);
            var count = weeklyData.FirstOrDefault(d => d.Date == date)?.Count ?? 0;
            dto.Dates.Add(date.ToString("yyyy-MM-dd"));
            dto.Counts.Add(count);
        }

        return dto;
    }

    public async Task<IEnumerable<CategoryCountDto>> GetCategoryCountsAsync()
    {
        var counts = await _context.Categories
            .Select(c => new CategoryCountDto
            {
                CategoryName = c.Name,
                Count = c.DailyContentCategories.Count
            })
            .OrderByDescending(c => c.Count)
            .ToListAsync();

        return counts;
    }

    public async Task<HealthCheckDto> GetHealthCheckAsync()
    {
        var process = System.Diagnostics.Process.GetCurrentProcess();
        var uptime = (DateTime.UtcNow - process.StartTime.ToUniversalTime()).TotalHours;
        
        var last24Hours = DateTime.UtcNow.AddDays(-1);
        var errorCount = await _context.Logs
            .CountAsync(l => l.CreatedAt >= last24Hours && (l.Action.Contains("Error") || l.Action.Contains("Exception") || l.Action.Contains("Fail")));

        var status = errorCount < 5 ? "OK" : (errorCount < 20 ? "Warning" : "Critical");

        return new HealthCheckDto
        {
            UptimeHours = Math.Round(uptime, 2),
            AverageResponseTimeMs = 45.5, // Varsayılan veya middleware'den gelen değer
            ErrorCountLast24Hours = errorCount,
            Status = status
        };
    }

    public async Task<IEnumerable<SpecialDayCountdownDto>> GetSpecialDaysCountdownAsync()
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow.Date);

        var upcomingDays = await _context.SpecialDays
            .Where(sd => sd.Date >= today)
            .OrderBy(sd => sd.Date)
            .Take(3)
            .Select(sd => new
            {
                sd.Name,
                sd.Date
            })
            .ToListAsync();

        return upcomingDays.Select(sd => new SpecialDayCountdownDto
        {
            Name = sd.Name,
            Date = sd.Date.ToDateTime(TimeOnly.MinValue),
            DaysLeft = sd.Date.DayNumber - today.DayNumber
        }).ToList();
    }

    public async Task<IEnumerable<ContentTypeTrendDto>> GetContentTypeTrendsAsync()
    {
        var today = DateTime.UtcNow.Date;
        var startDate = today.AddDays(-29);

        var data = await _context.DailyContents
            .Where(c => c.CreatedAt >= startDate)
            .GroupBy(c => new { c.Type, c.CreatedAt.Date })
            .Select(g => new { g.Key.Type, g.Key.Date, Count = g.Count() })
            .ToListAsync();

        var trends = new List<ContentTypeTrendDto>();
        var types = new[] { 1, 2, 3, 4 }; 

        foreach (var type in types)
        {
            var typeName = GetTypeName(type);
            var trend = new ContentTypeTrendDto { Type = typeName };

            for (int i = 0; i < 30; i++)
            {
                var date = startDate.AddDays(i);
                var count = data.FirstOrDefault(d => d.Type == (Domain.Enums.ContentType)type && d.Date == date)?.Count ?? 0;
                trend.Last30Days.Add(count);
            }
            
            trends.Add(trend);
        }

        return trends;
    }
}
