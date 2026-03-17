using Application.Dashboard.Queries;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DashboardController : ControllerBase
{
    private readonly IMediator _mediator;

    public DashboardController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("user-stats")]
    public async Task<IActionResult> GetUserStats()
    {
        var result = await _mediator.Send(new GetUserStatsQuery());
        return Ok(result);
    }

    [HttpGet("upcoming-special-days")]
    public async Task<IActionResult> GetUpcomingSpecialDays()
    {
        var result = await _mediator.Send(new GetUpcomingSpecialDaysQuery());
        return Ok(result);
    }

    [HttpGet("content-type-distribution")]
    public async Task<IActionResult> GetContentTypeDistribution()
    {
        var result = await _mediator.Send(new GetContentTypeDistributionQuery());
        return Ok(result);
    }

    [HttpGet("recent-contents")]
    public async Task<IActionResult> GetRecentContents()
    {
        var result = await _mediator.Send(new GetRecentContentsQuery());
        return Ok(result);
    }

    [HttpGet("specialday-content-ratio")]
    public async Task<IActionResult> GetSpecialDayContentRatio()
    {
        var result = await _mediator.Send(new GetSpecialDayContentRatioQuery());
        return Ok(result);
    }

    [HttpGet("daily-growth")]
    public async Task<IActionResult> GetDailyGrowth()
    {
        var result = await _mediator.Send(new GetDailyGrowthQuery());
        return Ok(result);
    }

    [HttpGet("weekly-content-activity")]
    public async Task<IActionResult> GetWeeklyContentActivity()
    {
        var result = await _mediator.Send(new GetWeeklyContentActivityQuery());
        return Ok(result);
    }

    [HttpGet("category-counts")]
    public async Task<IActionResult> GetCategoryCounts()
    {
        var result = await _mediator.Send(new GetCategoryCountsQuery());
        return Ok(result);
    }

    [HttpGet("health")]
    public async Task<IActionResult> GetHealthCheck()
    {
        var result = await _mediator.Send(new GetHealthCheckQuery());
        return Ok(result);
    }

    [HttpGet("special-days-countdown")]
    public async Task<IActionResult> GetSpecialDaysCountdown()
    {
        var result = await _mediator.Send(new GetSpecialDaysCountdownQuery());
        return Ok(result);
    }

    [HttpGet("content-type-trends")]
    public async Task<IActionResult> GetContentTypeTrends()
    {
        var result = await _mediator.Send(new GetContentTypeTrendsQuery());
        return Ok(result);
    }
}
