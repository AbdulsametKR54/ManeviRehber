using System;
using System.Threading.Tasks;
using Application.ZikrRecords.Commands.CreateZikrRecord;
using Application.ZikrRecords.Queries.GetDailyZikrSummary;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class ZikrController : ControllerBase
{
    private readonly IMediator _mediator;

    public ZikrController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateZikrRecordCommand command)
    {
        return Ok(new { Id = await _mediator.Send(command) });
    }

    [HttpGet("daily-summary")]
    public async Task<IActionResult> GetDailySummary()
    {
        return Ok(await _mediator.Send(new GetDailyZikrSummaryQuery()));
    }
}
