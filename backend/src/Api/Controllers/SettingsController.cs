using System;
using System.Threading.Tasks;
using Application.Settings.Commands.CreateSetting;
using Application.Settings.Commands.UpdateSetting;
using Application.Settings.Commands.DeleteSetting;
using Application.Settings.Queries.GetSettings;
using Application.Settings.Queries.GetSettingById;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MediatR;

namespace Api.Controllers;

[Authorize(Roles = "Admin")]
[ApiController]
[Route("api/[controller]")]
public class SettingsController : ControllerBase
{
    private readonly IMediator _mediator;

    public SettingsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        return Ok(await _mediator.Send(new GetSettingsQuery()));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await _mediator.Send(new GetSettingByIdQuery { Id = id });
        if (result == null)
            return NotFound();

        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateSettingCommand command)
    {
        return Ok(await _mediator.Send(command));
    }

    /// <summary>
    /// Ayar kaydını günceller.
    /// </summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, UpdateSettingCommand command)
    {
        if (id != command.Id)
            return BadRequest("ID uyuşmazlığı.");

        await _mediator.Send(command);
        return NoContent();
    }

    /// <summary>
    /// Ayar kaydını siler.
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _mediator.Send(new DeleteSettingCommand { Id = id });
        return NoContent();
    }
}
