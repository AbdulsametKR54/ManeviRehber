using Application.Categories.Commands.CreateCategory;
using Application.Categories.Commands.UpdateCategory;
using Application.Categories.Commands.DeleteCategory;
using Application.Categories.Queries.GetCategoryList;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Application.Categories.Queries.GetPagedCategoriesQuery;

namespace Api.Controllers;

[Authorize(Roles = "Admin,Editor")]
[ApiController]
[Route("api/[controller]")]
public class CategoryController : ControllerBase
{
    private readonly IMediator _mediator;

    public CategoryController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateCategoryCommand command)
    {
        var id = await _mediator.Send(command);
        return Ok(new { Id = id });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, UpdateCategoryCommand command)
    {
        if (id != command.Id)
            return BadRequest("Id uyuşmuyor.");

        await _mediator.Send(command);
        return Ok(new { Message = "Kategori güncellendi." });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _mediator.Send(new DeleteCategoryCommand(id));
        return Ok(new { Message = "Kategori silindi." });
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var categories = await _mediator.Send(new GetCategoryListQuery());
        return Ok(categories);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var category = await _mediator.Send(new Application.Categories.Queries.GetCategoryByIdQuery.GetCategoryByIdQuery { Id = id });
        if (category == null)
            return NotFound("Kategori bulunamadı.");
        return Ok(category);
    }

    [HttpGet("paged")]
    public async Task<IActionResult> GetPaged(
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        var result = await _mediator.Send(new GetPagedCategoriesQuery
        {
            Search = search,
            Page = page,
            PageSize = pageSize
        });

        return Ok(result);
    }
}