using System;
using System.Threading.Tasks;
using Application.DailyContents.Commands.CreateDailyContent;
using Application.DailyContents.Commands.UpdateDailyContent;
using Application.DailyContents.Commands.DeleteDailyContent;
using Application.DailyContents.Queries.GetDailyContents;
using Application.DailyContents.Queries.GetDailyContentById;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MediatR;
using Application.DailyContents.Queries.GetPagedDailyContentsQuery;

namespace Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class DailyContentsController : ControllerBase
{
    private readonly IMediator _mediator;

    public DailyContentsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] Guid? categoryId = null, [FromQuery] Guid? specialDayId = null)
    {
        return Ok(await _mediator.Send(new GetDailyContentsQuery { CategoryId = categoryId, SpecialDayId = specialDayId }));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await _mediator.Send(new GetDailyContentByIdQuery { Id = id });
        if (result == null)
            return NotFound();

        return Ok(result);
    }

    [HttpPost]
    [Authorize(Roles = "Admin,Editor")]
    public async Task<IActionResult> Create(CreateDailyContentCommand command)
    {
        var id = await _mediator.Send(command);
        return Ok(new { id = id });
    }

    /// <summary>
    /// Günlük içerik kaydını günceller.
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin,Editor")]
    public async Task<IActionResult> Update(Guid id, UpdateDailyContentCommand command)
    {
        if (id != command.Id)
            return BadRequest("ID uyuşmazlığı.");

        await _mediator.Send(command);
        return NoContent();
    }

    /// <summary>
    /// Günlük içerik kaydını siler.
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin,Editor")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _mediator.Send(new DeleteDailyContentCommand { Id = id });
        return NoContent();
    }

    [HttpGet("paged")]
    public async Task<IActionResult> GetPaged(
        [FromQuery] string? search,
        [FromQuery] DateTime? date,
        [FromQuery] int? type,
        [FromQuery] Guid? categoryId,
        [FromQuery] Guid? specialDayId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        var result = await _mediator.Send(new GetPagedDailyContentsQuery
        {
            Search = search,
            Date = date,
            Type = type,
            CategoryId = categoryId,
            SpecialDayId = specialDayId,
            Page = page,
            PageSize = pageSize
        });

        return Ok(result);
    }
}
