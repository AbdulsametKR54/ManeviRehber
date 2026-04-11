using System;
using System.Threading.Tasks;
using Application.Favorites.Commands.CreateFavorite;
using Application.Favorites.Commands.DeleteFavorite;
using Application.Favorites.Queries.GetFavorites;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class FavoritesController : ControllerBase
{
    private readonly IMediator _mediator;

    public FavoritesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        return Ok(await _mediator.Send(new GetFavoritesQuery()));
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateFavoriteCommand command)
    {
        var id = await _mediator.Send(command);
        return Ok(new { id = id });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _mediator.Send(new DeleteFavoriteCommand { Id = id });
        return NoContent();
    }
}
