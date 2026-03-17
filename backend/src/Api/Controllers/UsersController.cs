using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MediatR;
using Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IMediator _mediator;

    public UsersController(ApplicationDbContext context, IMediator mediator)
    {
        _context = context;
        _mediator = mediator;
    }

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 10)
    {
        var result = await _mediator.Send(new Application.Users.Queries.GetUsersList.GetUsersListQuery
        {
            Page = page,
            PageSize = pageSize
        });
        
        return Ok(result);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create(Application.Users.Commands.CreateUser.CreateUserCommand command)
    {
        var id = await _mediator.Send(command);
        return Ok(new { Id = id });
    }

    [HttpPut("{id}/role")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateRole(Guid id, [FromBody] Application.Users.Commands.UpdateUserRole.UpdateUserRoleCommand command)
    {
        command.Id = id;
        await _mediator.Send(command);
        return NoContent();
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _mediator.Send(new Application.Users.Commands.DeleteUser.DeleteUserCommand { Id = id });
        return NoContent();
    }

    [HttpPatch("{id}/deactivate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Deactivate(Guid id)
    {
        await _mediator.Send(new Application.Users.Commands.DeactivateUser.DeactivateUserCommand { Id = id });
        return NoContent();
    }

    [HttpPatch("{id}/activate")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Activate(Guid id)
    {
        await _mediator.Send(new Application.Users.Commands.ActivateUser.ActivateUserCommand { Id = id });
        return NoContent();
    }

    [HttpPut("me")]
    [Authorize] // All logged in users
    public async Task<IActionResult> UpdateProfile([FromBody] Application.Users.Commands.UpdateProfile.UpdateProfileCommand command)
    {
        await _mediator.Send(command);
        return NoContent();
    }
}
