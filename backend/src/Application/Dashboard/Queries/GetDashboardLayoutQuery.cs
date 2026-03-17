using Application.Common.Interfaces;
using Application.Dashboard.Dtos;
using MediatR;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace Application.Dashboard.Queries;

public class GetDashboardLayoutQuery : IRequest<DashboardLayoutDto>
{
}

public class GetDashboardLayoutQueryHandler : IRequestHandler<GetDashboardLayoutQuery, DashboardLayoutDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public GetDashboardLayoutQueryHandler(IApplicationDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }

    public async Task<DashboardLayoutDto> Handle(GetDashboardLayoutQuery request, CancellationToken cancellationToken)
    {
        var userId = _currentUserService.UserId ?? Guid.Empty;
        if (userId == Guid.Empty) return new DashboardLayoutDto();
        
        var layout = await _context.UserDashboardLayouts
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

        if (layout == null)
        {
            // Default layout
            return new DashboardLayoutDto
            {
                WidgetsOrder = new[] { "dailyGrowth", "weeklyContentActivity", "categoryDistribution", "healthCheck", "specialDaysCountdown", "contentTypeTrends" },
                Visible = new Dictionary<string, bool> 
                {
                    { "dailyGrowth", true },
                    { "weeklyContentActivity", true },
                    { "categoryDistribution", true },
                    { "healthCheck", true },
                    { "specialDaysCountdown", true },
                    { "contentTypeTrends", true }
                }
            };
        }

        return new DashboardLayoutDto
        {
            WidgetsOrder = JsonSerializer.Deserialize<string[]>(layout.WidgetsOrderJson) ?? Array.Empty<string>(),
            Visible = JsonSerializer.Deserialize<Dictionary<string, bool>>(layout.VisibleJson) ?? new Dictionary<string, bool>(),
            Size = JsonSerializer.Deserialize<Dictionary<string, object>>(layout.SizeJson) ?? new Dictionary<string, object>(),
            AutoRefresh = JsonSerializer.Deserialize<Dictionary<string, bool>>(layout.AutoRefreshJson) ?? new Dictionary<string, bool>(),
            AutoRefreshInterval = JsonSerializer.Deserialize<Dictionary<string, int>>(layout.AutoRefreshIntervalJson) ?? new Dictionary<string, int>()
        };
    }
}
