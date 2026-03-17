using Application.Dashboard.Commands;
using Application.Dashboard.Queries;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers;

[Authorize]
[ApiController]
[Route("api/dashboard/layout")]
public class DashboardLayoutController : ControllerBase
{
    private readonly IMediator _mediator;

    public DashboardLayoutController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetLayout()
    {
        var result = await _mediator.Send(new GetDashboardLayoutQuery());
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> SaveLayout([FromBody] SaveDashboardLayoutCommand command)
    {
        await _mediator.Send(command);
        return Ok();
    }
}
