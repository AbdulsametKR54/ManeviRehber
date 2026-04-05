using System;
using System.Threading.Tasks;
using Application.SpecialDays.Commands.CreateSpecialDay;
using Application.SpecialDays.Commands.UpdateSpecialDay;
using Application.SpecialDays.Commands.DeleteSpecialDay;
using Application.SpecialDays.Queries.GetSpecialDays;
using Application.SpecialDays.Queries.GetSpecialDayById;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MediatR;
using Application.SpecialDays.Queries.GetPagedSpecialDaysQuery;

namespace Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class SpecialDaysController : ControllerBase
{
    private readonly IMediator _mediator;

    public SpecialDaysController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        return Ok(await _mediator.Send(new GetSpecialDaysQuery()));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await _mediator.Send(new GetSpecialDayByIdQuery { Id = id });
        if (result == null)
            return NotFound();

        return Ok(result);
    }

    [HttpPost]
    [Authorize(Roles = "Admin,Editor")]
    public async Task<IActionResult> Create(CreateSpecialDayCommand command)
    {
        return Ok(await _mediator.Send(command));
    }

    /// <summary>
    /// Özel gün kaydını günceller.
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin,Editor")]
    public async Task<IActionResult> Update(Guid id, UpdateSpecialDayCommand command)
    {
        if (id != command.Id)
            return BadRequest("ID uyuşmazlığı.");

        await _mediator.Send(command);
        return NoContent();
    }

    /// <summary>
    /// Özel gün kaydını siler.
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin,Editor")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _mediator.Send(new DeleteSpecialDayCommand { Id = id });
        return NoContent();
    }

    [HttpGet("paged")]
    public async Task<IActionResult> GetPaged(
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        var result = await _mediator.Send(new GetPagedSpecialDaysQuery
        {
            Search = search,
            Page = page,
            PageSize = pageSize
        });

        return Ok(result);
    }
}
