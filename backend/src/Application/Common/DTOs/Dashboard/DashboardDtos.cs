namespace Application.Common.DTOs.Dashboard;

public class MonthlyUserStatDto
{
    public string Month { get; set; } = string.Empty;
    public int TotalUsers { get; set; }
    public int NewUsers { get; set; }
}

public class UserStatsDto
{
    public List<MonthlyUserStatDto> Monthly { get; set; } = new();
    public int ActiveUsers { get; set; }
    public int PassiveUsers { get; set; }
    public int NewUsersThisMonth { get; set; }
}

public class UpcomingSpecialDayDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Date { get; set; } = string.Empty;
}

public class ContentTypeDistributionDto
{
    public int Ayet { get; set; }
    public int Hadis { get; set; }
    public int Dua { get; set; }
    public int Soz { get; set; }
}

public class RecentContentDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string TypeName { get; set; } = string.Empty;
    public string Date { get; set; } = string.Empty;
    public List<string> Categories { get; set; } = new();
}

public class SpecialDayContentRatioDto
{
    public int SpecialDayContents { get; set; }
    public int NormalContents { get; set; }
}

public class DailyGrowthDto
{
    public int TodayCount { get; set; }
    public int YesterdayCount { get; set; }
    public int Difference { get; set; } // Today - Yesterday
    public string Trend { get; set; } = string.Empty; // "up", "down", "equal"
}

public class WeeklyContentActivityDto
{
    public List<string> Dates { get; set; } = new(); // "2026-03-10"
    public List<int> Counts { get; set; } = new();
}

public class CategoryCountDto
{
    public string CategoryName { get; set; } = string.Empty;
    public int Count { get; set; }
}

public class HealthCheckDto
{
    public double UptimeHours { get; set; }
    public double AverageResponseTimeMs { get; set; }
    public int ErrorCountLast24Hours { get; set; }
    public string Status { get; set; } = string.Empty; // "OK", "Warning", "Critical"
}

public class SpecialDayCountdownDto
{
    public string Name { get; set; } = string.Empty;
    public DateTime Date { get; set; }
    public int DaysLeft { get; set; }
}

public class ContentTypeTrendDto
{
    public string Type { get; set; } = string.Empty; // Dua, Hadis, Söz, Ayet
    public List<int> Last30Days { get; set; } = new();
}
